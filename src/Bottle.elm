module Bottle exposing (..)

import Html exposing (Html, h1, h3, text, div, p)
import Html.Attributes exposing (style)
import Element exposing (Element, px, styled, none)
import Keyboard exposing (KeyCode)
import Set
import Time exposing (Time)
import Random exposing (Generator(..))
import RandomExtra exposing (selectWithDefault)
import Grid exposing (Cell, Column, Grid)


type Speed
    = Low
    | Med
    | High


type Mode
    = PlacingPill Pill Grid.Coords
    | Falling


type Pill
    = Horizontal Color Color
    | Vertical Color Color


type Type
    = Virus
    | Pill (Maybe Dependent)


type alias Dependent =
    Direction


type Color
    = Red
    | Blue
    | Yellow


type alias Contents =
    ( Color, Type )


type alias Bottle =
    Grid Contents


type alias Model =
    { contents : Bottle
    , mode : Mode
    , next : ( Color, Color )
    , controls : Int -> Maybe Direction
    }


init : Model
init =
    { contents = Grid.fromDimensions 8 16
    , mode = Falling
    , next = ( Red, Red )
    , controls = (\_ -> Nothing)
    }


withNext : ( Color, Color ) -> Model -> Model
withNext next model =
    { model | next = next }


withVirus : Color -> Grid.Coords -> Model -> Model
withVirus color coords model =
    { model
        | contents =
            Grid.setState ( color, Virus )
                coords
                model.contents
    }


withControls : (Int -> Maybe Direction) -> Model -> Model
withControls controls model =
    { model | controls = controls }


type Msg
    = NewPill ( Color, Color )
    | KeyDown (Maybe Direction)
    | TickTock Time


type Direction
    = Up
    | Down
    | Left
    | Right


subscriptions : Speed -> Model -> Sub Msg
subscriptions speed model =
    Sub.batch
        [ Time.every (tickForSpeed speed) TickTock
        , Keyboard.downs (model.controls >> KeyDown)
        ]


tickForSpeed : Speed -> Time
tickForSpeed speed =
    case speed of
        High ->
            300 * Time.millisecond

        Med ->
            700 * Time.millisecond

        Low ->
            Time.second



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update msg model =
    case ( model.mode, msg ) of
        ( Falling, NewPill next ) ->
            let
                ( a, b ) =
                    model.next
            in
                withNothing
                    { model
                        | mode = PlacingPill (Horizontal a b) ( 4, 0 )
                        , next = next
                    }

        ( PlacingPill pill ( x, y ), KeyDown key ) ->
            let
                moveIfAvailable : Pill -> Grid.Coords -> ( Model, Cmd Msg, Maybe msg )
                moveIfAvailable pill coords =
                    withNothing
                        (if isAvailable coords pill model.contents then
                            { model | mode = PlacingPill pill coords }
                         else
                            model
                        )
            in
                case key of
                    Just Up ->
                        let
                            newPill =
                                case pill of
                                    Horizontal a b ->
                                        Vertical a b

                                    Vertical a b ->
                                        Horizontal b a
                        in
                            moveIfAvailable newPill ( x, y )

                    Just Left ->
                        moveIfAvailable pill ( x - 1, y )

                    Just Right ->
                        moveIfAvailable pill ( x + 1, y )

                    Just Down ->
                        moveIfAvailable pill ( x, y + 1 )

                    Nothing ->
                        withNothing model

        ( _, KeyDown _ ) ->
            withNothing model

        ( _, TickTock _ ) ->
            advance model

        _ ->
            withNothing model


withNothing : Model -> ( Model, Cmd Msg, Maybe msg )
withNothing model =
    ( model, Cmd.none, Nothing )


advance : Model -> ( Model, Cmd Msg, Maybe msg )
advance model =
    case model.mode of
        PlacingPill pill ( x, y ) ->
            let
                newCoords =
                    ( x, y + 1 )

                afterPill : Pill -> Grid.Coords -> Model -> Model
                afterPill pill coords model =
                    let
                        newContents =
                            addPill pill coords model.contents

                        modify =
                            if canSweep newContents then
                                sweep
                            else
                                (\m -> { m | contents = fall newContents })
                    in
                        modify
                            { model
                                | mode = Falling
                                , contents = newContents
                            }
            in
                withNothing
                    (if isAvailable newCoords pill model.contents then
                        { model | mode = PlacingPill pill newCoords }
                     else
                        afterPill pill ( x, y ) model
                    )

        Falling ->
            let
                timeToFall : Bool
                timeToFall =
                    model.contents
                        |> Grid.filter
                            (\{ coords } -> canFall coords model.contents)
                        |> (List.isEmpty >> not)
            in
                if timeToFall then
                    ( { model
                        | mode = Falling
                        , contents =
                            fall model.contents
                      }
                    , Cmd.none
                    , Nothing
                    )
                else if canSweep model.contents then
                    ( sweep model, Cmd.none, Nothing )
                else
                    ( model
                    , Random.generate NewPill <|
                        generatePill
                    , Nothing
                    )


addPill : Pill -> Grid.Coords -> Bottle -> Bottle
addPill pill coords bottle =
    colorCoords pill coords
        |> List.foldl
            (\( coords, color, dependent ) grid ->
                Grid.setState (( color, Pill (Just dependent) )) coords grid
            )
            bottle


colorCoords : Pill -> Grid.Coords -> List ( Grid.Coords, Color, Dependent )
colorCoords pill coords =
    let
        ( a_color, a_dep, b_color, b_dep ) =
            case pill of
                Horizontal a b ->
                    ( a, Right, b, Left )

                Vertical a b ->
                    ( a, Down, b, Up )
    in
        case pillCoordsPair pill coords of
            first :: second :: [] ->
                [ ( first, a_color, a_dep ), ( second, b_color, b_dep ) ]

            _ ->
                []


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


sweep : Model -> Model
sweep ({ contents } as model) =
    let
        coordsLosingDependent =
            contents
                |> Grid.filter
                    (\({ coords, state } as cell) ->
                        case state of
                            Just ( _, Pill (Just dependent) ) ->
                                if isCleared coords contents then
                                    True
                                else
                                    False

                            _ ->
                                False
                    )
                |> List.map
                    (\{ coords, state } ->
                        case state of
                            Just ( _, Pill (Just dependent) ) ->
                                coordsWithDirection coords dependent

                            _ ->
                                Debug.crash "Shouldn't have made it thru the preceding filter"
                    )
                |> Set.fromList

        swept =
            Grid.map
                (\({ coords, state } as cell) ->
                    if isCleared coords contents then
                        { cell | state = Nothing }
                    else if Set.member coords coordsLosingDependent then
                        case state of
                            Just ( color, _ ) ->
                                { cell | state = Just ( color, Pill Nothing ) }

                            Nothing ->
                                cell
                    else
                        cell
                )
                contents
    in
        { model | contents = swept }


coordsWithDirection : Grid.Coords -> Direction -> Grid.Coords
coordsWithDirection ( x, y ) direction =
    case direction of
        Up ->
            ( x, y - 1 )

        Down ->
            ( x, y + 1 )

        Left ->
            ( x - 1, y )

        Right ->
            ( x + 1, y )



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

                        Just ( _, Pill Nothing ) ->
                            hasRoom tail

                        Just ( _, Pill dependent ) ->
                            canFall head.coords bottle

                        Just ( _, Virus ) ->
                            False
    in
        case cell.state of
            Just ( _, Pill Nothing ) ->
                (Grid.below coords bottle |> hasRoom)

            Just ( _, Pill (Just Up) ) ->
                (Grid.below coords bottle |> hasRoom)

            Just ( _, Pill (Just Down) ) ->
                canFall (coordsWithDirection coords Down) bottle

            Just ( _, Pill (Just dependent) ) ->
                -- Left or Right
                (Grid.below coords bottle |> hasRoom)
                    && (bottle
                            |> Grid.below (coordsWithDirection coords dependent)
                            |> hasRoom
                       )

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
totalViruses contents =
    List.length <|
        Grid.filter
            (\c ->
                case c.state of
                    Just ( _, Virus ) ->
                        True

                    _ ->
                        False
            )
            contents


hasConflict : Model -> Bool
hasConflict { mode, contents } =
    case mode of
        PlacingPill pill coords ->
            pillCoordsPair pill coords
                |> List.map (\p -> Grid.isEmpty p contents)
                |> (List.any not)

        _ ->
            False



-- GENERATORS


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


generatePill : Generator ( Color, Color )
generatePill =
    Random.pair generateColor generateColor


generateColor : Generator Color
generateColor =
    selectWithDefault Blue [ Red, Yellow, Blue ]



-- VIEW


view : Model -> Html msg
view { contents, mode } =
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

                                    Just ( color, Pill dependent ) ->
                                        viewPill dependent color

                                    Just ( color, Virus ) ->
                                        viewVirus color
                            )
                            column
                        )
                )
                (case mode of
                    PlacingPill pill coords ->
                        addPill pill coords contents

                    _ ->
                        contents
                )
            )
        ]


viewPill : Maybe Dependent -> Color -> Html msg
viewPill dependent color =
    viewColor color
        8
        (case dependent of
            Just Up ->
                [ ( "border-top-left-radius", px 0 ), ( "border-top-right-radius", px 0 ) ]

            Just Down ->
                [ ( "border-bottom-left-radius", px 0 ), ( "border-bottom-right-radius", px 0 ) ]

            Just Left ->
                [ ( "border-top-left-radius", px 0 ), ( "border-bottom-left-radius", px 0 ) ]

            Just Right ->
                [ ( "border-top-right-radius", px 0 ), ( "border-bottom-right-radius", px 0 ) ]

            Nothing ->
                []
        )
        []


viewVirus : Color -> Html msg
viewVirus color =
    viewColor color 3 [] [ text "◔̯◔" ]


viewColor : Color -> Int -> List ( String, String ) -> List (Html msg) -> Html msg
viewColor color radius extraStyle =
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
                 , ( "border-top-left-radius", px radius )
                 , ( "border-top-right-radius", px radius )
                 , ( "border-bottom-left-radius", px radius )
                 , ( "border-bottom-right-radius", px radius )
                 ]
                    ++ cellStyle
                    ++ extraStyle
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



-- UTILS


subLists : Int -> List a -> List (List a)
subLists len list =
    if List.length list < len then
        []
    else
        (List.take len list) :: subLists len (List.drop 1 list)
