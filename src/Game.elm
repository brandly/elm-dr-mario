module Game exposing (..)

import Grid exposing (Cell, Column, Grid)
import Html exposing (Html, h1, h3, text, div, p)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Keyboard exposing (KeyCode)
import Random exposing (Generator(..))
import RandomExtra exposing (selectWithDefault)
import Time exposing (Time)
import Element exposing (Element, px, styled)


type Mode
    = PlacingPill Pill Grid.Coords
    | Falling


type Pill
    = Horizontal Color Color
    | Vertical Color Color


type Speed
    = Low
    | Med
    | High


type Type
    = Virus
    | Pill


type Color
    = Red
    | Blue
    | Yellow


type alias Contents =
    ( Color, Type )


type alias Bottle =
    Grid Contents


type alias State =
    { bottle : Bottle
    , mode : Mode
    , next : ( Color, Color )
    , level : Int
    , score : Int
    , speed : Speed
    }


type Msg
    = TickTock Time
    | NewPill ( Color, Color )
    | KeyDown Key


type Key
    = Up
    | Down
    | Left
    | Right
    | Noop


init :
    { level : Int
    , bottle : Bottle
    , score : Int
    , colors : ( Color, Color )
    , speed : Speed
    }
    -> State
init { level, bottle, score, colors, speed } =
    { bottle = bottle
    , mode = Falling
    , next = colors
    , level = level
    , score = score
    , speed = speed
    }


emptyBottle : Grid val
emptyBottle =
    Grid.fromDimensions 8 16


subscriptions : State -> Sub Msg
subscriptions { speed } =
    Sub.batch
        [ Time.every (tickForSpeed speed) TickTock
        , Keyboard.downs
            ((\keyCode ->
                case keyCode of
                    38 ->
                        Up

                    37 ->
                        Left

                    39 ->
                        Right

                    40 ->
                        Down

                    _ ->
                        Noop
             )
                >> KeyDown
            )
        ]



-- SETTINGS --


virusesForLevel : Int -> Int
virusesForLevel level =
    min 84 (4 * level + 4)


tickForSpeed : Speed -> Time
tickForSpeed speed =
    case speed of
        High ->
            300 * Time.millisecond

        Med ->
            700 * Time.millisecond

        Low ->
            Time.second


pointsForClearedViruses : Speed -> Int -> Int
pointsForClearedViruses speed cleared =
    applyNtimes (cleared - 1)
        ((*) 2)
        (case speed of
            Low ->
                100

            Med ->
                200

            High ->
                300
        )



-- UPDATE --


update : Msg -> State -> ( State, Cmd Msg )
update action model =
    case ( model.mode, action ) of
        ( PlacingPill pill ( x, y ), TickTock _ ) ->
            let
                newCoords =
                    ( x, y + 1 )

                afterPill : Pill -> Grid.Coords -> State -> State
                afterPill pill coords model =
                    let
                        newBottle =
                            addPill pill coords model.bottle

                        modify =
                            if canSweep newBottle then
                                sweep
                            else
                                (\m -> { m | bottle = fall newBottle })
                    in
                        modify
                            { model
                                | mode = Falling
                                , bottle = newBottle
                            }
            in
                ( if isAvailable newCoords pill model.bottle then
                    { model | mode = PlacingPill pill newCoords }
                  else
                    afterPill pill ( x, y ) model
                , Cmd.none
                )

        ( Falling, TickTock _ ) ->
            let
                timeToFall : Bool
                timeToFall =
                    model.bottle
                        |> Grid.filter
                            (\{ coords } -> canFall coords model.bottle)
                        |> (List.isEmpty >> not)
            in
                if timeToFall then
                    ( { model
                        | mode = Falling
                        , bottle =
                            fall model.bottle
                      }
                    , Cmd.none
                    )
                else if canSweep model.bottle then
                    ( sweep model, Cmd.none )
                else
                    ( model
                    , Random.generate NewPill <|
                        generatePill
                    )

        ( Falling, NewPill next ) ->
            let
                ( a, b ) =
                    model.next
            in
                ( { model
                    | mode = PlacingPill (Horizontal a b) ( 4, 0 )
                    , next = next
                  }
                , Cmd.none
                )

        ( _, NewPill _ ) ->
            ( model, Cmd.none )

        ( PlacingPill pill ( x, y ), KeyDown key ) ->
            let
                moveIfAvailable : Pill -> Grid.Coords -> ( State, Cmd Msg )
                moveIfAvailable pill coords =
                    if isAvailable coords pill model.bottle then
                        ( { model | mode = PlacingPill pill coords }, Cmd.none )
                    else
                        ( model, Cmd.none )
            in
                case key of
                    Up ->
                        let
                            newPill =
                                case pill of
                                    Horizontal a b ->
                                        Vertical a b

                                    Vertical a b ->
                                        Horizontal b a
                        in
                            moveIfAvailable newPill ( x, y )

                    Left ->
                        moveIfAvailable pill ( x - 1, y )

                    Right ->
                        moveIfAvailable pill ( x + 1, y )

                    Down ->
                        moveIfAvailable pill ( x, y + 1 )

                    Noop ->
                        ( model, Cmd.none )

        ( _, KeyDown _ ) ->
            ( model, Cmd.none )


addPill : Pill -> Grid.Coords -> Bottle -> Bottle
addPill pill coords bottle =
    colorCoords pill coords
        |> List.foldl
            (\( color, coords ) grid ->
                Grid.setState (( color, Pill )) coords grid
            )
            bottle


colorCoords : Pill -> Grid.Coords -> List ( Color, Grid.Coords )
colorCoords pill coords =
    let
        ( a, b ) =
            case pill of
                Horizontal a b ->
                    ( a, b )

                Vertical a b ->
                    ( a, b )
    in
        case pillCoordsPair pill coords of
            first :: second :: [] ->
                [ ( a, first ), ( b, second ) ]

            _ ->
                []


sweep : State -> State
sweep ({ bottle, score, speed } as model) =
    let
        sweepableVirusCount : Bottle -> Int
        sweepableVirusCount grid =
            grid
                |> Grid.filter
                    (\({ coords, state } as cell) ->
                        case state of
                            Just ( _, Virus ) ->
                                isCleared coords grid

                            _ ->
                                False
                    )
                |> (List.length)

        sweptBottle =
            Grid.map
                (\({ coords } as cell) ->
                    if isCleared coords bottle then
                        { cell | state = Nothing }
                    else
                        cell
                )
                bottle

        additionalPoints =
            (sweepableVirusCount >> (pointsForClearedViruses speed)) bottle
    in
        { model | bottle = sweptBottle, score = score + additionalPoints }


fall : Bottle -> Bottle
fall bottle =
    Grid.map
        (\({ coords, state } as cell) ->
            let
                ( x, y ) =
                    coords
            in
                if canFall ( x, y ) bottle then
                    -- look above
                    if canFall ( x, y - 1 ) bottle then
                        { cell
                            | state =
                                .state <| Grid.findCellAtCoords ( x, y - 1 ) bottle
                        }
                    else
                        { cell | state = Nothing }
                else if state == Nothing && canFall ( x, y - 1 ) bottle then
                    { cell
                        | state =
                            .state <|
                                Grid.findCellAtCoords ( x, y - 1 ) bottle
                    }
                else
                    cell
        )
        bottle



-- QUERIES


pillCoordsPair : Pill -> Grid.Coords -> List Grid.Coords
pillCoordsPair pill ( x, y ) =
    case pill of
        Horizontal _ _ ->
            [ ( x, y + 1 ), ( x + 1, y + 1 ) ]

        Vertical _ _ ->
            [ ( x, y ), ( x, y + 1 ) ]


isAvailable : Grid.Coords -> Pill -> Bottle -> Bool
isAvailable (( x, y ) as coords) pill grid =
    let
        aboveBottom =
            y < Grid.height grid

        withinRight =
            case pill of
                Vertical _ _ ->
                    x <= Grid.width grid

                Horizontal _ _ ->
                    x < Grid.width grid

        inBottle =
            (x >= 1)
                && withinRight
                && aboveBottom

        noOccupant =
            pillCoordsPair pill coords
                |> List.map (\p -> Grid.isEmpty p grid)
                |> List.all identity
    in
        inBottle && noOccupant


canSweep : Bottle -> Bool
canSweep grid =
    grid
        |> Grid.filter
            (\cell ->
                isCleared cell.coords grid
            )
        |> (List.length >> (/=) 0)


canFall : Grid.Coords -> Bottle -> Bool
canFall coords bottle =
    let
        cell =
            Grid.findCellAtCoords coords bottle

        hasRoom : List (Cell Contents) -> Bool
        hasRoom cells =
            case cells of
                [] ->
                    False

                head :: tail ->
                    case head.state of
                        Nothing ->
                            True

                        Just ( _, Pill ) ->
                            hasRoom tail

                        Just ( _, Virus ) ->
                            False
    in
        case cell.state of
            Just ( _, Pill ) ->
                (Grid.below coords bottle |> hasRoom)

            _ ->
                False


isCleared : Grid.Coords -> Bottle -> Bool
isCleared ( x, y ) grid =
    let
        cell =
            Grid.findCellAtCoords ( x, y ) grid

        len =
            4

        horizontal : List (List (Cell Contents))
        horizontal =
            neighbors (\offset -> ( x + offset, y ))

        vertical : List (List (Cell Contents))
        vertical =
            neighbors (\offset -> ( x, y + offset ))

        neighbors f =
            List.range (len * -1 + 1) (len - 1)
                |> List.map f
                |> List.map (\coords -> Grid.findCellAtCoords coords grid)
                |> subLists len
    in
        case cell.state of
            Nothing ->
                False

            Just ( color, _ ) ->
                List.any
                    (List.all
                        (\cell ->
                            case cell.state of
                                Just ( c, _ ) ->
                                    c == color

                                Nothing ->
                                    False
                        )
                    )
                    (vertical ++ horizontal)


totalViruses : Bottle -> Int
totalViruses grid =
    List.length <|
        Grid.filter
            (\c ->
                case c.state of
                    Just ( _, Virus ) ->
                        True

                    _ ->
                        False
            )
            grid


isOver : State -> Bool
isOver state =
    case state.mode of
        PlacingPill pill coords ->
            pillCoordsPair pill coords
                |> List.map (\p -> Grid.isEmpty p state.bottle)
                |> (List.all not)

        _ ->
            False



-- GENERATORS --


generatePill : Generator ( Color, Color )
generatePill =
    Random.pair generateColor generateColor


generateColor : Generator Color
generateColor =
    selectWithDefault Blue [ Red, Yellow, Blue ]


generateEmptyCoords : Bottle -> Generator Grid.Coords
generateEmptyCoords grid =
    let
        emptyCoords : List ( Int, Int )
        emptyCoords =
            grid
                |> Grid.filter
                    (\{ coords } ->
                        Tuple.second coords >= 5 && (Grid.isEmpty coords grid)
                    )
                |> List.map .coords
    in
        selectWithDefault ( -1, -1 ) emptyCoords



-- VIEW --


view : Maybe msg -> State -> Html msg
view pauseMsg state =
    div [ style [ ( "display", "flex" ) ] ]
        [ viewBottle
            (case state.mode of
                PlacingPill pill coords ->
                    addPill pill coords state.bottle

                _ ->
                    state.bottle
            )
        , div [ style [ ( "margin", "0 16px" ) ] ]
            [ h3 [] [ text "next" ]
            , div [ style [ ( "display", "flex" ) ] ]
                [ (Tuple.first >> viewPill) state.next
                , (Tuple.second >> viewPill) state.next
                ]
            , h3 [] [ text "level" ]
            , p [] [ (toString >> text) state.level ]
            , h3 [] [ text "speed" ]
            , p [] [ (toString >> text) state.speed ]
            , h3 [] [ text "virus" ]
            , p [] [ text <| toString (totalViruses state.bottle) ]
            , h3 [] [ text "score" ]
            , p [] [ (toString >> text) state.score ]
            , case pauseMsg of
                Just msg ->
                    Html.button [ onClick msg ] [ text "pause" ]

                Nothing ->
                    text ""
            ]
        ]


viewBottle : Bottle -> Html msg
viewBottle bottle =
    div []
        [ div
            [ style
                [ ( "display", "inline-block" )
                , ( "border", "3px solid #CCC" )
                , ( "border-radius", "3px" )
                , ( "background", "#000" )
                ]
            ]
            (List.map
                (\column ->
                    div
                        [ style [ ( "display", "inline-block" ), ( "vertical-align", "top" ) ] ]
                        (List.map
                            (\cell ->
                                case cell.state of
                                    Nothing ->
                                        div [ style cellStyle ] []

                                    Just ( color, Pill ) ->
                                        viewPill color

                                    Just ( color, Virus ) ->
                                        viewVirus color
                            )
                            column
                        )
                )
                bottle
            )
        ]


viewPill : Color -> Html msg
viewPill color =
    viewColor color 8 []


viewVirus : Color -> Html msg
viewVirus color =
    viewColor color 3 [ text "◔̯◔" ]


viewColor : Color -> Int -> List (Html msg) -> Html msg
viewColor color radius =
    let
        bg =
            case color of
                Red ->
                    "#e8005a"

                Blue ->
                    "#39bdff"

                Yellow ->
                    "#ffbd03"
    in
        div
            [ style
                ([ ( "background-color", bg )
                 , ( "border-radius", px radius )
                 ]
                    ++ cellStyle
                )
            ]


cellStyle : List ( String, String )
cellStyle =
    [ ( "width", px cellSize )
    , ( "height", px cellSize )
    , ( "border", "1px solid black" )
    ]


cellSize : Int
cellSize =
    24



-- UTILS --


subLists : Int -> List a -> List (List a)
subLists len list =
    if List.length list < len then
        []
    else
        (List.take len list) :: subLists len (List.drop 1 list)


applyNtimes : Int -> (a -> a) -> a -> a
applyNtimes n f x =
    if n <= 0 then
        x
    else if n == 1 then
        f x
    else
        f (applyNtimes (n - 1) f x)
