module Bottle exposing (..)

import Direction exposing (Direction(..))
import Grid exposing (Cell, Grid)
import Pill exposing (Color(..), Orientation(..), Pill)
import Random exposing (Generator(..))
import RandomExtra exposing (selectWithDefault)
import Speed exposing (Speed(..))


type alias Bottle =
    Grid Contents


type alias Contents =
    ( Color, CellType )


type CellType
    = Virus
    | Pill (Maybe Dependent)


type alias Dependent =
    Direction


totalViruses : Bottle -> Int
totalViruses bottle =
    List.length <|
        Grid.filter
            (\c ->
                case c.state of
                    Just ( _, Virus ) ->
                        True

                    _ ->
                        False
            )
            bottle


isAvailable : Pill -> Bottle -> Bool
isAvailable pill grid =
    let
        ( x, y ) =
            pill.coords

        aboveBottom =
            y < Grid.height grid

        withinRight =
            case pill.orientation of
                Vertical _ ->
                    x <= Grid.width grid

                Horizontal _ ->
                    x < Grid.width grid

        inBottle =
            (x >= 1)
                && withinRight
                && aboveBottom

        noOccupant =
            Pill.coordsPair pill
                |> List.map (\p -> Grid.isEmpty p grid)
                |> List.all identity
    in
    inBottle && noOccupant


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

                        Just ( _, Pill _ ) ->
                            canFall head.coords bottle

                        Just ( _, Virus ) ->
                            False
    in
    case cell.state of
        Just ( _, Pill Nothing ) ->
            Grid.below coords bottle |> hasRoom

        Just ( _, Pill (Just Up) ) ->
            Grid.below coords bottle |> hasRoom

        Just ( _, Pill (Just Down) ) ->
            canFall (coordsWithDirection Down coords) bottle

        Just ( _, Pill (Just dependent) ) ->
            -- Left or Right
            (Grid.below coords bottle |> hasRoom)
                && (bottle
                        |> Grid.below (coordsWithDirection dependent coords)
                        |> hasRoom
                   )

        _ ->
            False


canSweep : Bottle -> Bool
canSweep grid =
    grid
        |> Grid.filter
            (\cell ->
                isCleared cell.coords grid
            )
        |> (List.length >> (/=) 0)


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
                    (\cell_ ->
                        case cell_.state of
                            Just ( c, _ ) ->
                                c == color

                            Nothing ->
                                False
                    )
                )
                (vertical ++ horizontal)


addPill : Pill -> Bottle -> Bottle
addPill pill bottle =
    colorCoords pill
        |> List.foldl
            (\( coords_, color, dependent ) grid ->
                Grid.setState ( color, Pill (Just dependent) ) coords_ grid
            )
            bottle


fall : Bottle -> Bottle
fall bottle =
    Grid.map
        (\({ coords, state } as cell) ->
            let
                above =
                    coordsWithDirection Up coords
            in
            if canFall coords bottle then
                -- look above
                if canFall above bottle then
                    { cell | state = .state <| Grid.findCellAtCoords above bottle }

                else
                    { cell | state = Nothing }

            else if state == Nothing && canFall above bottle then
                { cell | state = .state <| Grid.findCellAtCoords above bottle }

            else
                cell
        )
        bottle


colorCoords : Pill -> List ( Grid.Coords, Color, Dependent )
colorCoords pill =
    let
        ( ( a_color, a_dep ), ( b_color, b_dep ) ) =
            case pill.orientation of
                Horizontal ( a, b ) ->
                    ( ( a, Right ), ( b, Left ) )

                Vertical ( a, b ) ->
                    ( ( a, Down ), ( b, Up ) )
    in
    case Pill.coordsPair pill of
        first :: second :: [] ->
            [ ( first, a_color, a_dep ), ( second, b_color, b_dep ) ]

        _ ->
            []



-- GENERATORS


generateEmptyCoords : Bottle -> Generator Grid.Coords
generateEmptyCoords grid =
    let
        emptyCoords : List ( Int, Int )
        emptyCoords =
            grid
                |> Grid.filter
                    (\{ coords } ->
                        Tuple.second coords >= 5 && Grid.isEmpty coords grid
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


generateBomb : Bottle -> Generator Int
generateBomb bottle =
    selectWithDefault -1
        (Grid.topRow bottle
            |> List.filter
                (\c ->
                    case c.state of
                        Just _ ->
                            False

                        Nothing ->
                            True
                )
            |> List.map (.coords >> Tuple.first)
        )



-- UTILS


subLists : Int -> List a -> List (List a)
subLists len list =
    if List.length list < len then
        []

    else
        List.take len list :: subLists len (List.drop 1 list)


coordsWithDirection : Direction -> Grid.Coords -> Grid.Coords
coordsWithDirection direction ( x, y ) =
    case direction of
        Up ->
            ( x, y - 1 )

        Down ->
            ( x, y + 1 )

        Left ->
            ( x - 1, y )

        Right ->
            ( x + 1, y )


getColor : Int -> Color
getColor index =
    case remainderBy 3 index of
        0 ->
            Red

        1 ->
            Blue

        _ ->
            Yellow
