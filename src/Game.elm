module Game exposing (..)

import Grid exposing (Cell, Type(..), Column, Grid)
import Html exposing (Html, h1, h3, text, div, p)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Keyboard exposing (KeyCode)
import Random exposing (Generator(..))
import Time exposing (Time)
import Element exposing (Element, px, styled)
import Virus exposing (Color(..))


type Mode
    = Pill Pill Grid.Pair
    | Fall


type Pill
    = Horizontal Color Color
    | Vertical Color Color


type Speed
    = Low
    | Med
    | High


type alias State =
    { bottle : Grid
    , mode : Mode
    , next : ( Color, Color )
    , level : Int
    , score : Int
    , speed : Speed
    }


type Msg
    = TickTock Time
    | KeyChange Bool KeyCode
    | NewPill ( Color, Color )


emptyBottle : Grid
emptyBottle =
    Grid.fromDimensions ( 8, 16 )


init :
    { level : Int
    , bottle : Grid
    , score : Int
    , colors : ( Color, Color )
    , speed : Speed
    }
    -> State
init { level, bottle, score, colors, speed } =
    { bottle = bottle
    , mode = Fall
    , next = colors
    , level = level
    , score = score
    , speed = speed
    }


virusesForLevel : Int -> Int
virusesForLevel level =
    -- TODO: better types?
    if level <= 20 then
        4 * level + 4
    else
        84


isOver : State -> Bool
isOver state =
    case state.mode of
        Pill pill pair ->
            pairsForPill pill pair
                |> List.map (\p -> Grid.isEmpty p state.bottle)
                |> (List.all Basics.identity >> not)

        _ ->
            False


subscriptions : State -> Sub Msg
subscriptions { speed } =
    let
        time =
            Time.every (tickForSpeed speed) TickTock

        keys =
            [ Keyboard.downs (KeyChange True)
            , Keyboard.ups (KeyChange False)
            ]
    in
        Sub.batch (time :: keys)


tickForSpeed : Speed -> Time
tickForSpeed speed =
    case speed of
        High ->
            300 * Time.millisecond

        Med ->
            700 * Time.millisecond

        Low ->
            Time.second


randomNewPill : Generator ( Color, Color )
randomNewPill =
    Random.pair Virus.generateColor Virus.generateColor


pairsForPill : Pill -> Grid.Pair -> List Grid.Pair
pairsForPill pill ( x, y ) =
    case pill of
        Horizontal _ _ ->
            [ ( x, y + 1 ), ( x + 1, y + 1 ) ]

        Vertical _ _ ->
            [ ( x, y ), ( x, y + 1 ) ]


addPill : Pill -> Grid.Pair -> Grid -> Grid
addPill pill pair bottle =
    colorPairs pill pair
        |> List.foldl
            (\( color, pair ) grid ->
                Grid.updateCellsAtPairs
                    (\c -> { c | state = Just ( color, Grid.Pill ) })
                    [ pair ]
                    grid
            )
            bottle


colorPairs : Pill -> Grid.Pair -> List ( Color, Grid.Pair )
colorPairs pill pair =
    let
        ( a, b ) =
            case pill of
                Horizontal a b ->
                    ( a, b )

                Vertical a b ->
                    ( a, b )
    in
        case pairsForPill pill pair of
            first :: second :: [] ->
                [ ( a, first ), ( b, second ) ]

            _ ->
                []


update : Msg -> State -> ( State, Cmd Msg )
update action model =
    case action of
        TickTock _ ->
            case model.mode of
                Pill pill ( x, y ) ->
                    let
                        newPair =
                            ( x, y + 1 )
                    in
                        ( if isAvailable newPair pill model.bottle then
                            { model | mode = Pill pill newPair }
                          else
                            afterPill pill ( x, y ) model
                        , Cmd.none
                        )

                Fall ->
                    let
                        timeToFall : Bool
                        timeToFall =
                            model.bottle
                                |> Grid.filter
                                    (\{ x, y } -> canFall ( x, y ) model.bottle)
                                |> (List.isEmpty >> not)
                    in
                        if timeToFall then
                            ( { model
                                | mode = Fall
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
                                randomNewPill
                            )

        NewPill next ->
            let
                ( a, b ) =
                    model.next
            in
                ( { model
                    | mode = Pill (Horizontal a b) ( 4, 0 )
                    , next = next
                  }
                , Cmd.none
                )

        KeyChange True code ->
            let
                moveIfAvailable : Pill -> Grid.Pair -> ( State, Cmd Msg )
                moveIfAvailable pill pair =
                    if isAvailable pair pill model.bottle then
                        ( { model | mode = Pill pill pair }, Cmd.none )
                    else
                        ( model, Cmd.none )
            in
                case model.mode of
                    Pill pill ( x, y ) ->
                        case code of
                            38 ->
                                let
                                    newPill =
                                        case pill of
                                            Horizontal a b ->
                                                Vertical a b

                                            Vertical a b ->
                                                Horizontal b a
                                in
                                    moveIfAvailable newPill ( x, y )

                            37 ->
                                moveIfAvailable pill ( x - 1, y )

                            39 ->
                                moveIfAvailable pill ( x + 1, y )

                            40 ->
                                moveIfAvailable pill ( x, y + 1 )

                            _ ->
                                ( model, Cmd.none )

                    _ ->
                        ( model, Cmd.none )

        KeyChange False _ ->
            ( model, Cmd.none )


isAvailable : Grid.Pair -> Pill -> Grid -> Bool
isAvailable (( x, y ) as pair) pill grid =
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
            pairsForPill pill pair
                |> List.map (\p -> Grid.isEmpty p grid)
                |> List.all Basics.identity
    in
        inBottle && noOccupant


afterPill : Pill -> Grid.Pair -> State -> State
afterPill pill pair model =
    let
        newBottle =
            addPill pill pair model.bottle

        modify =
            if canSweep newBottle then
                sweep
            else
                (\m -> { m | bottle = fall newBottle })
    in
        modify
            { model
                | mode = Fall
                , bottle = newBottle
            }


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


applyNtimes : Int -> (a -> a) -> a -> a
applyNtimes n f x =
    if n <= 0 then
        x
    else if n == 1 then
        f x
    else
        f (applyNtimes (n - 1) f x)


canSweep : Grid -> Bool
canSweep grid =
    sweepableCount grid > 0


sweepableCount : Grid -> Int
sweepableCount grid =
    grid
        |> Grid.filter
            (\({ x, y } as cell) ->
                isCleared ( x, y ) grid
            )
        |> (List.length)


sweepableVirusCount : Grid -> Int
sweepableVirusCount grid =
    grid
        |> Grid.filter
            (\({ x, y, state } as cell) ->
                case state of
                    Just ( _, Virus ) ->
                        isCleared ( x, y ) grid

                    _ ->
                        False
            )
        |> (List.length)


sweep : State -> State
sweep ({ bottle, score, speed } as model) =
    let
        sweptBottle =
            Grid.map
                (\({ x, y } as cell) ->
                    if isCleared ( x, y ) bottle then
                        { cell | state = Nothing }
                    else
                        cell
                )
                bottle

        additionalPoints =
            (sweepableVirusCount >> (pointsForClearedViruses speed)) bottle
    in
        { model | bottle = sweptBottle, score = score + additionalPoints }


canFall : Grid.Pair -> Grid -> Bool
canFall pair bottle =
    let
        cell =
            Grid.findCellAtPair pair bottle

        hasRoom : List Cell -> Bool
        hasRoom cells =
            case cells of
                [] ->
                    False

                head :: tail ->
                    case head.state of
                        Nothing ->
                            True

                        Just ( _, Grid.Pill ) ->
                            hasRoom tail

                        Just ( _, Virus ) ->
                            False
    in
        case cell.state of
            Just ( _, Grid.Pill ) ->
                (Grid.below pair bottle |> hasRoom)

            _ ->
                False


fall : Grid -> Grid
fall bottle =
    Grid.map
        (\({ x, y, state } as cell) ->
            if canFall ( x, y ) bottle then
                -- look above
                if canFall ( x, y - 1 ) bottle then
                    { cell
                        | state =
                            .state <| Grid.findCellAtPair ( x, y - 1 ) bottle
                    }
                else
                    { cell | state = Nothing }
            else if state == Nothing && canFall ( x, y - 1 ) bottle then
                { cell
                    | state =
                        .state <|
                            Grid.findCellAtPair ( x, y - 1 ) bottle
                }
            else
                cell
        )
        bottle


isCleared : Grid.Pair -> Grid -> Bool
isCleared ( x, y ) grid =
    let
        cell =
            Grid.findCellAtPair ( x, y ) grid

        len =
            4

        horizontal : List (List Cell)
        horizontal =
            neighbors (\offset -> ( x + offset, y ))

        vertical : List (List Cell)
        vertical =
            neighbors (\offset -> ( x, y + offset ))

        neighbors f =
            List.range (len * -1 + 1) (len - 1)
                |> List.map f
                |> List.map (\pair -> Grid.findCellAtPair pair grid)
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


subLists : Int -> List a -> List (List a)
subLists len list =
    if List.length list < len then
        []
    else
        (List.take len list) :: subLists len (List.drop 1 list)



-- VIEW --


view : Maybe msg -> State -> Html msg
view pauseMsg state =
    div [ style [ ( "display", "flex" ) ] ]
        [ viewBottle
            (case state.mode of
                Pill pill pair ->
                    addPill pill pair state.bottle

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
            , p [] [ text <| toString (Grid.totalViruses state.bottle) ]
            , h3 [] [ text "score" ]
            , p [] [ (toString >> text) state.score ]
            , case pauseMsg of
                Just msg ->
                    Html.button [ onClick msg ] [ text "pause" ]

                Nothing ->
                    text ""
            ]
        ]


viewBottle : Grid -> Html msg
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

                                    Just ( color, Grid.Pill ) ->
                                        viewPill color

                                    Just ( color, Grid.Virus ) ->
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
