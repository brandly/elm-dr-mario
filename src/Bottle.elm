module Bottle exposing (..)

import Html exposing (Html, h1, h3, text, div, p)
import Html.Attributes exposing (style)
import Element exposing (Element, px, styled, none)
import Keyboard exposing (KeyCode)
import Random exposing (Generator(..))
import RandomExtra exposing (selectWithDefault)
import Grid exposing (Cell, Column, Grid)


type Mode
    = PlacingPill Pill Grid.Coords
    | Falling


type Pill
    = Horizontal Color Color
    | Vertical Color Color


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


type alias Model =
    { contents : Bottle
    , mode : Mode
    , next : ( Color, Color )
    , controls : Int -> Maybe Direction
    }


init : (Int -> Maybe Direction) -> Model
init controls =
    { contents = Grid.fromDimensions 8 16
    , mode = Falling
    , next = ( Red, Red )
    , controls = controls
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


type Msg
    = NewPill ( Color, Color )
    | KeyDown (Maybe Direction)


type Direction
    = Up
    | Down
    | Left
    | Right


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.downs (model.controls >> KeyDown)



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

        _ ->
            withNothing model


withNothing : Model -> ( Model, Cmd Msg, Maybe msg )
withNothing model =
    ( model, Cmd.none, Nothing )


advance : Model -> ( Model, Cmd Msg )
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
                ( if isAvailable newCoords pill model.contents then
                    { model | mode = PlacingPill pill newCoords }
                  else
                    afterPill pill ( x, y ) model
                , Cmd.none
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
                    )
                else if canSweep model.contents then
                    ( sweep model, Cmd.none )
                else
                    ( model
                    , Random.generate NewPill <|
                        generatePill
                    )


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

        swept =
            Grid.map
                (\({ coords } as cell) ->
                    if isCleared coords contents then
                        { cell | state = Nothing }
                    else
                        cell
                )
                contents
    in
        { model | contents = swept }



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

                                    Just ( color, Pill ) ->
                                        viewPill color

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



-- UTILS


subLists : Int -> List a -> List (List a)
subLists len list =
    if List.length list < len then
        []
    else
        (List.take len list) :: subLists len (List.drop 1 list)
