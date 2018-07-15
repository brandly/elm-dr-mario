module Grid exposing (..)

import Virus exposing (Color(..))


type Type
    = Virus
    | Pill


type alias CellState =
    Maybe ( Color, Type )


type alias Cell =
    { x : Int
    , y : Int
    , state : CellState
    }


type alias Column =
    List Cell


type alias Grid =
    List Column


type alias Pair =
    ( Int, Int )


fromDimensions : Pair -> Grid
fromDimensions ( width, height ) =
    let
        makeColumn : Int -> Column
        makeColumn x =
            List.range 1 height
                |> List.map (\y -> Cell x y Nothing)
    in
        List.range 1 width
            |> List.map makeColumn


width : Grid -> Int
width grid =
    List.length grid


height : Grid -> Int
height grid =
    case grid of
        [] ->
            0

        head :: _ ->
            List.length head


gridToCells : Grid -> List Cell
gridToCells grid =
    List.concat grid


filter : (Cell -> Bool) -> Grid -> List Cell
filter filter grid =
    gridToCells grid |> List.filter filter


findCell : (Cell -> Bool) -> Grid -> Cell
findCell match grid =
    let
        defaultCell =
            Cell -1 -1 Nothing
    in
        gridToCells grid |> findMatching defaultCell match


findCellAtPair : Pair -> Grid -> Cell
findCellAtPair ( x, y ) grid =
    grid |> findCell (\cell -> cell.x == x && cell.y == y)


isEmpty : Pair -> Grid -> Bool
isEmpty pair grid =
    findCellAtPair pair grid |> (.state >> (==) Nothing)


findMatching : a -> (a -> Bool) -> List a -> a
findMatching default match list =
    let
        matches =
            list |> List.filter match
    in
        case List.head matches of
            Just empty ->
                empty

            Nothing ->
                default


map : (Cell -> Cell) -> Grid -> Grid
map f grid =
    List.map (List.map f) grid


setPairState : CellState -> Pair -> Grid -> Grid
setPairState state pair grid =
    updateCellAtPair
        (\c -> { c | state = state })
        pair
        grid


updateCellAtPair : (Cell -> Cell) -> Pair -> Grid -> Grid
updateCellAtPair update pair grid =
    updateCell update (findCellAtPair pair grid) grid


updateCells : (Cell -> Cell) -> List Cell -> Grid -> Grid
updateCells update cells grid =
    List.foldl (updateCell update) grid cells


updateCell : (Cell -> Cell) -> Cell -> Grid -> Grid
updateCell update cell grid =
    let
        replaceCell : Column -> Column
        replaceCell =
            List.map
                (\og ->
                    if og.x == cell.x && og.y == cell.y then
                        update cell
                    else
                        og
                )
    in
        grid |> List.map replaceCell


totalViruses : Grid -> Int
totalViruses grid =
    List.length <|
        filter
            (\c ->
                case c.state of
                    Just ( _, Virus ) ->
                        True

                    _ ->
                        False
            )
            grid


below : Pair -> Grid -> List Cell
below ( x, y ) grid =
    case List.head <| List.drop (x - 1) grid of
        Nothing ->
            []

        Just column ->
            List.drop y column
