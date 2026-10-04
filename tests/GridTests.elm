module GridTests exposing (suite)

import Expect
import Grid exposing (Grid)
import Test exposing (Test, describe, test)


grid : Grid Char
grid =
    Grid.fromDimensions 3 4


suite : Test
suite =
    describe "Grid"
        [ describe "Grid.findCellAtCoords"
            [ test "finds an empty cell inside the grid" <|
                \_ ->
                    Grid.findCellAtCoords ( 2, 3 ) grid
                        |> Expect.equal (Just { coords = ( 2, 3 ), state = Nothing })
            , test "finds an occupied cell" <|
                \_ ->
                    Grid.findCellAtCoords ( 3, 4 ) (Grid.setState 'a' ( 3, 4 ) grid)
                        |> Expect.equal (Just { coords = ( 3, 4 ), state = Just 'a' })
            , test "finds nothing outside the grid" <|
                \_ ->
                    [ ( 0, 1 ), ( 4, 1 ), ( 1, 0 ), ( 1, 5 ), ( -1, -1 ) ]
                        |> List.map (\coords -> Grid.findCellAtCoords coords grid)
                        |> Expect.equal [ Nothing, Nothing, Nothing, Nothing, Nothing ]
            ]
        , describe "Grid.isEmpty"
            [ test "an untouched cell is empty" <|
                \_ ->
                    Grid.isEmpty ( 1, 1 ) grid
                        |> Expect.equal True
            , test "an occupied cell is not empty" <|
                \_ ->
                    Grid.isEmpty ( 1, 1 ) (Grid.setState 'a' ( 1, 1 ) grid)
                        |> Expect.equal False
            , test "coords outside the grid are not empty" <|
                \_ ->
                    Grid.isEmpty ( 4, 1 ) grid
                        |> Expect.equal False
            ]
        , describe "Grid.setState"
            [ test "ignores coords outside the grid" <|
                \_ ->
                    Grid.setState 'a' ( 4, 1 ) grid
                        |> Expect.equal grid
            ]
        , describe "Grid.columns"
            [ test "lays cells out column by column, top to bottom" <|
                \_ ->
                    Grid.fromDimensions 2 2
                        |> Grid.setState 'a' ( 2, 1 )
                        |> Grid.columns
                        |> Expect.equal
                            [ [ { coords = ( 1, 1 ), state = Nothing }, { coords = ( 1, 2 ), state = Nothing } ]
                            , [ { coords = ( 2, 1 ), state = Just 'a' }, { coords = ( 2, 2 ), state = Nothing } ]
                            ]
            ]
        , describe "Grid.map"
            [ test "clearing a cell leaves it empty" <|
                \_ ->
                    grid
                        |> Grid.setState 'a' ( 1, 1 )
                        |> Grid.map (\cell -> { cell | state = Nothing })
                        |> Expect.equal grid
            ]
        , describe "Grid.below"
            [ test "lists the cells under some coords, nearest first" <|
                \_ ->
                    Grid.below ( 2, 2 ) grid
                        |> List.map .coords
                        |> Expect.equal [ ( 2, 3 ), ( 2, 4 ) ]
            , test "is empty outside the walls" <|
                \_ ->
                    Grid.below ( 0, 2 ) grid
                        |> Expect.equal []
            ]
        ]
