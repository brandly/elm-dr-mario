module Grid exposing
    ( Cell
    , Column
    , Coords
    , Grid
    , below
    , columns
    , difference
    , filter
    , findCellAtCoords
    , fromDimensions
    , get
    , height
    , isEmpty
    , map
    , occupied
    , setState
    , topRow
    , width
    )

import Dict exposing (Dict)


type alias Cell val =
    { coords : Coords
    , state : Maybe val
    }


type alias Column val =
    List (Cell val)


{-| A `width` by `height` grid, indexed from `( 1, 1 )` in the top left.
Only occupied cells are stored, so a missing key means an empty cell.
-}
type Grid val
    = Grid
        { width : Int
        , height : Int
        , cells : Dict Coords val
        }


type alias Coords =
    ( Int, Int )


fromDimensions : Int -> Int -> Grid val
fromDimensions width_ height_ =
    Grid { width = width_, height = height_, cells = Dict.empty }


width : Grid val -> Int
width (Grid grid) =
    grid.width


height : Grid val -> Int
height (Grid grid) =
    grid.height


inBounds : Coords -> Grid val -> Bool
inBounds ( x, y ) (Grid grid) =
    x >= 1 && x <= grid.width && y >= 1 && y <= grid.height


cellAt : Coords -> Grid val -> Cell val
cellAt coords grid =
    Cell coords (get coords grid)


columns : Grid val -> List (Column val)
columns grid =
    List.range 1 (width grid)
        |> List.map
            (\x ->
                List.range 1 (height grid)
                    |> List.map (\y -> cellAt ( x, y ) grid)
            )


toList : Grid val -> List (Cell val)
toList grid =
    List.concat (columns grid)


filter : (Cell val -> Bool) -> Grid val -> List (Cell val)
filter predicate grid =
    toList grid |> List.filter predicate


{-| The occupied cells and what occupies them, column by column from the
top left. Empty cells are skipped, so this is cheaper than `filter` when
only occupants matter.
-}
occupied : Grid val -> List ( Coords, val )
occupied (Grid grid) =
    -- `Dict` orders keys by x and then y, which is column by column
    Dict.toList grid.cells


{-| The cells of `a` whose state differs from the same cell in `b`, as
judged by `diff`.
-}
difference : (Maybe val -> Maybe val -> Bool) -> Grid val -> Grid val -> List (Cell val)
difference diff a b =
    List.map2
        (\y z ->
            if diff y.state z.state then
                Just y

            else
                Nothing
        )
        (toList a)
        (toList b)
        |> List.filterMap identity


{-| The cell at these coords, or `Nothing` when they fall outside the grid.
-}
findCellAtCoords : Coords -> Grid val -> Maybe (Cell val)
findCellAtCoords coords grid =
    if inBounds coords grid then
        Just (cellAt coords grid)

    else
        Nothing


{-| What occupies these coords, or `Nothing` when the cell is empty or
outside the grid. Use `findCellAtCoords` to tell those two apart.
-}
get : Coords -> Grid val -> Maybe val
get coords (Grid grid) =
    Dict.get coords grid.cells


{-| Whether these coords hold an empty cell. Coords outside the grid hold no
cell at all, so they are never empty.
-}
isEmpty : Coords -> Grid val -> Bool
isEmpty coords grid =
    inBounds coords grid && get coords grid == Nothing


{-| Work out every cell's new state from its coords and its current state.
-}
map : (Coords -> Maybe a -> Maybe b) -> Grid a -> Grid b
map f ((Grid grid) as grid_) =
    Grid
        { width = grid.width
        , height = grid.height
        , cells =
            toList grid_
                |> List.filterMap
                    (\{ coords, state } ->
                        f coords state |> Maybe.map (Tuple.pair coords)
                    )
                |> Dict.fromList
        }


{-| Occupy the cell at these coords. Coords outside the grid are ignored.
-}
setState : val -> Coords -> Grid val -> Grid val
setState state coords ((Grid grid) as grid_) =
    if inBounds coords grid_ then
        Grid { grid | cells = Dict.insert coords state grid.cells }

    else
        grid_


{-| The cells beneath these coords in the same column, nearest first.
-}
below : Coords -> Grid val -> List (Cell val)
below ( x, y ) grid =
    List.range (y + 1) (height grid)
        |> List.filterMap (\y_ -> findCellAtCoords ( x, y_ ) grid)


{-| The cells along the top row, from left to right.
-}
topRow : Grid val -> List (Cell val)
topRow grid =
    List.range 1 (width grid)
        |> List.filterMap (\x -> findCellAtCoords ( x, 1 ) grid)
