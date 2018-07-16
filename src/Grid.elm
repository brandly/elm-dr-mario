module Grid exposing (..)


type alias Cell val =
    { x : Int
    , y : Int
    , state : Maybe val
    }


type alias Column val =
    List (Cell val)


type alias Grid val =
    List (Column val)


type alias Pair =
    ( Int, Int )


fromDimensions : Int -> Int -> Grid val
fromDimensions width height =
    let
        makeColumn : Int -> Column val
        makeColumn x =
            List.range 1 height
                |> List.map (\y -> Cell x y Nothing)
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


findCell : (Cell val -> Bool) -> Grid val -> Cell val
findCell match grid =
    let
        defaultCell =
            Cell -1 -1 Nothing
    in
        toList grid |> findMatching defaultCell match


findCellAtPair : Pair -> Grid val -> Cell val
findCellAtPair ( x, y ) grid =
    grid |> findCell (\cell -> cell.x == x && cell.y == y)


isEmpty : Pair -> Grid val -> Bool
isEmpty pair grid =
    findCellAtPair pair grid |> (.state >> (==) Nothing)


findMatching : Cell a -> (Cell a -> Bool) -> List (Cell a) -> Cell a
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


map : (Cell val -> Cell val) -> Grid val -> Grid val
map f grid =
    List.map (List.map f) grid


setPairState : val -> Pair -> Grid val -> Grid val
setPairState state pair grid =
    updateCellAtPair
        (\c -> { c | state = Just state })
        pair
        grid


updateCellAtPair : (Cell val -> Cell val) -> Pair -> Grid val -> Grid val
updateCellAtPair update ( x, y ) grid =
    let
        replaceCell : Column val -> Column val
        replaceCell =
            List.map
                (\cell ->
                    if cell.x == x && cell.y == y then
                        update cell
                    else
                        cell
                )
    in
        grid |> List.map replaceCell


below : Pair -> Grid val -> List (Cell val)
below ( x, y ) grid =
    case List.head <| List.drop (x - 1) grid of
        Nothing ->
            []

        Just column ->
            List.drop y column
