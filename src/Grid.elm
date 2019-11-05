module Grid exposing
    ( Cell
    , Column
    , Coords
    , Grid
    , any
    , below
    , difference
    , filter
    , filterMap
    , findCellAtCoords
    , fromDimensions
    , height
    , isEmpty
    , map
    , setState
    , topRow
    , width
    , zip
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
fromDimensions width_ height_ =
    let
        makeColumn : Int -> Column val
        makeColumn x =
            List.range 1 height_
                |> List.map (\y -> Cell ( x, y ) Nothing)
    in
    List.range 1 width_
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
filter predicate grid =
    toList grid |> List.filter predicate


filterMap : (Cell a -> Maybe b) -> Grid a -> List b
filterMap predicate grid =
    toList grid |> List.filterMap predicate


difference : (Maybe val -> Maybe val -> Bool) -> Grid val -> Grid val -> List (Cell val)
difference diff a b =
    zip (toList a) (toList b)
        |> List.filterMap
            (\( y, z ) ->
                if diff y.state z.state then
                    Just y

                else
                    Nothing
            )


any : (Cell a -> Bool) -> Grid a -> Bool
any predicate =
    toList >> List.any predicate


{-| The zip function takes in two lists and returns a combined
list. It combines the elements of each list pairwise until one
of the lists runs out of elements.

    zip [ 1, 2, 3 ] [ 'a', 'b', 'c' ] == [ ( 1, 'a' ), ( 2, 'b' ), ( 3, 'c' ) ]

<http://elm-lang.org/examples/zip>

-}
zip : List a -> List b -> List ( a, b )
zip =
    List.map2 Tuple.pair


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


map : (Cell a -> Cell b) -> Grid a -> Grid b
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


topRow : Grid val -> List (Cell val)
topRow grid =
    let
        go result grid_ =
            case grid_ of
                head :: tail ->
                    case head of
                        Just cell ->
                            go (cell :: result) tail

                        Nothing ->
                            go result tail

                _ ->
                    result
    in
    go [] (List.map List.head grid)
