module Grid exposing (..)


type Color
    = Red
    | Blue
    | Yellow


type Type
    = Virus
    | Pill


type alias Cell =
    { x : Int
    , y : Int
    , state : Maybe ( Color, Type )
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



--withBombPairs : List Pair -> Grid -> Grid
--withBombPairs pairs grid =
--    let
--        head =
--            case List.head pairs of
--                Just head ->
--                    head
--                Nothing ->
--                    ( -1, -1 )
--        tail =
--            case List.tail pairs of
--                Just tail ->
--                    tail
--                Nothing ->
--                    []
--        addBomb : Grid -> Grid
--        addBomb =
--            findCellAtPair head grid
--                |> updateCell (\cell -> { cell | bomb = True })
--    in
--        if List.length pairs > 0 then
--            withBombPairs
--                tail
--                (addBomb grid)
--        else
--            grid


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


updateCellsAtPairs : (Cell -> Cell) -> List Pair -> Grid -> Grid
updateCellsAtPairs update pairs grid =
    updateCells update (List.map (\p -> findCellAtPair p grid) pairs) grid


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


getNeighbors : Cell -> Grid -> List Cell
getNeighbors cell grid =
    grid |> filter (isNeighbor cell)


isNeighbor : Cell -> Cell -> Bool
isNeighbor a b =
    abs (a.x - b.x) <= 1 && abs (a.y - b.y) <= 1


totalViruses : Grid -> Int
totalViruses grid =
    List.length <| filter (\c -> c.state /= Nothing) grid
