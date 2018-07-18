module Grid
    exposing
        ( Cell
        , Column
        , Grid
        , Coords
        , fromDimensions
        , isEmpty
        , setState
        , map
        , filter
        , height
        , width
        , findCellAtCoords
        , below
        )


type alias Cell val =
    { coords : Coords
    , state : Maybe val
    }


type alias Column val =
    List (Cell val)


type alias Grid val =
    List (Column val)


type alias Coords =
    ( Int, Int )


fromDimensions : Int -> Int -> Grid val
fromDimensions width height =
    let
        makeColumn : Int -> Column val
        makeColumn x =
            List.range 1 height
                |> List.map (\y -> Cell ( x, y ) Nothing)
    in
        List.range 1 width
            |> List.map makeColumn


width : Grid val -> Int
width grid =
    List.length grid


height : Grid val -> Int
height grid =
    case grid of
        [] ->
            0

        head :: _ ->
            List.length head


toList : Grid val -> List (Cell val)
toList grid =
    List.concat grid


filter : (Cell val -> Bool) -> Grid val -> List (Cell val)
filter filter grid =
    toList grid |> List.filter filter


findCellAtCoords : Coords -> Grid val -> Cell val
findCellAtCoords coords grid =
    toList grid
        |> find (\cell -> cell.coords == coords)
        |> Maybe.withDefault (Cell ( -1, -1 ) Nothing)


find : (a -> Bool) -> List a -> Maybe a
find test list =
    list |> List.filter test |> List.head


isEmpty : Coords -> Grid val -> Bool
isEmpty coords grid =
    findCellAtCoords coords grid |> (.state >> (==) Nothing)


map : (Cell val -> Cell val) -> Grid val -> Grid val
map f grid =
    List.map (List.map f) grid


setState : val -> Coords -> Grid val -> Grid val
setState state coords grid =
    updateCellAtCoords
        (\c -> { c | state = Just state })
        coords
        grid


updateCellAtCoords : (Cell val -> Cell val) -> Coords -> Grid val -> Grid val
updateCellAtCoords update coords grid =
    map
        (\cell ->
            if cell.coords == coords then
                update cell
            else
                cell
        )
        grid


below : Coords -> Grid val -> List (Cell val)
below ( x, y ) grid =
    case List.head <| List.drop (x - 1) grid of
        Nothing ->
            []

        Just column ->
            List.drop y column
