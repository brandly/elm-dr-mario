module BottleTests exposing (suite)

import Bottle exposing (Bottle)
import Direction exposing (Direction(..))
import Expect
import Grid
import Pill exposing (Color(..), Orientation(..))
import Test exposing (Test, describe, test)



-- HELPERS


{-| The same dimensions the game uses, so the walls and the floor land
where `Env.init` puts them.
-}
emptyBottle : Bottle
emptyBottle =
    Grid.fromDimensions 8 16


withPills : List ( Grid.Coords, Color ) -> Bottle -> Bottle
withPills cells bottle =
    List.foldl
        (\( coords, color ) acc ->
            Grid.setState ( color, Bottle.Pill Nothing ) coords acc
        )
        bottle
        cells


withViruses : List ( Grid.Coords, Color ) -> Bottle -> Bottle
withViruses cells bottle =
    List.foldl
        (\( coords, color ) acc ->
            Grid.setState ( color, Bottle.Virus ) coords acc
        )
        bottle
        cells


{-| Half of a two-cell pill. The direction points at the other half.
-}
withHalf : Grid.Coords -> Color -> Direction -> Bottle -> Bottle
withHalf coords color dependent bottle =
    Grid.setState ( color, Bottle.Pill (Just dependent) ) coords bottle


row : Int -> List Int -> Color -> List ( Grid.Coords, Color )
row y xs color =
    List.map (\x -> ( ( x, y ), color )) xs


column : Int -> List Int -> Color -> List ( Grid.Coords, Color )
column x ys color =
    List.map (\y -> ( ( x, y ), color )) ys


stateAt : Grid.Coords -> Bottle -> Maybe Bottle.Contents
stateAt coords bottle =
    .state (Grid.findCellAtCoords coords bottle)


statesAt : List Grid.Coords -> Bottle -> List (Maybe Bottle.Contents)
statesAt coordsList bottle =
    List.map (\coords -> stateAt coords bottle) coordsList


pillAt : Orientation -> Grid.Coords -> Pill.Pill
pillAt orientation coords =
    { orientation = orientation, coords = coords }


applyTimes : Int -> (a -> a) -> a -> a
applyTimes n f value =
    if n <= 0 then
        value

    else
        applyTimes (n - 1) f (f value)



-- TESTS


suite : Test
suite =
    describe "Bottle"
        [ isClearedTests
        , canSweepTests
        , isAvailableTests
        , canFallTests
        , fallTests
        , addPillTests
        , miscTests
        ]


isClearedTests : Test
isClearedTests =
    describe "Bottle.isCleared"
        [ test "every cell of a horizontal run of four is cleared" <|
            \_ ->
                let
                    bottle =
                        withPills (row 16 [ 1, 2, 3, 4 ] Red) emptyBottle
                in
                List.map (\x -> Bottle.isCleared ( x, 16 ) bottle) [ 1, 2, 3, 4 ]
                    |> Expect.equal [ True, True, True, True ]
        , test "a horizontal run of three is not cleared" <|
            \_ ->
                let
                    bottle =
                        withPills (row 16 [ 1, 2, 3 ] Red) emptyBottle
                in
                List.map (\x -> Bottle.isCleared ( x, 16 ) bottle) [ 1, 2, 3 ]
                    |> Expect.equal [ False, False, False ]
        , test "every cell of a vertical run of four is cleared" <|
            \_ ->
                let
                    bottle =
                        withPills (column 1 [ 13, 14, 15, 16 ] Red) emptyBottle
                in
                List.map (\y -> Bottle.isCleared ( 1, y ) bottle) [ 13, 14, 15, 16 ]
                    |> Expect.equal [ True, True, True, True ]
        , test "four cells in a row of mixed colors are not cleared" <|
            \_ ->
                let
                    bottle =
                        emptyBottle
                            |> withPills (row 16 [ 1, 2, 4 ] Red)
                            |> withPills (row 16 [ 3 ] Blue)
                in
                List.map (\x -> Bottle.isCleared ( x, 16 ) bottle) [ 1, 2, 3, 4 ]
                    |> Expect.equal [ False, False, False, False ]
        , test "viruses count toward a run" <|
            \_ ->
                let
                    bottle =
                        emptyBottle
                            |> withPills (row 16 [ 1, 2, 3 ] Red)
                            |> withViruses [ ( ( 4, 16 ), Red ) ]
                in
                List.map (\x -> Bottle.isCleared ( x, 16 ) bottle) [ 1, 2, 3, 4 ]
                    |> Expect.equal [ True, True, True, True ]
        , test "a run of five clears all five cells" <|
            \_ ->
                let
                    bottle =
                        withPills (row 16 [ 1, 2, 3, 4, 5 ] Yellow) emptyBottle
                in
                List.map (\x -> Bottle.isCleared ( x, 16 ) bottle) [ 1, 2, 3, 4, 5 ]
                    |> Expect.equal [ True, True, True, True, True ]
        , test "an empty cell is never cleared" <|
            \_ ->
                Bottle.isCleared ( 5, 16 ) emptyBottle
                    |> Expect.equal False
        , test "a run does not wrap around the right wall" <|
            \_ ->
                let
                    -- (7,16) and (8,16) end row 16 while (1,15) and (2,15) sit
                    -- far away in the row above. They are only ever neighbors
                    -- in the flattened grid, never on the board.
                    bottle =
                        emptyBottle
                            |> withPills (row 16 [ 7, 8 ] Red)
                            |> withPills (row 15 [ 1, 2 ] Red)
                in
                List.map (\coords -> Bottle.isCleared coords bottle)
                    [ ( 7, 16 ), ( 8, 16 ), ( 1, 15 ), ( 2, 15 ) ]
                    |> Expect.equal [ False, False, False, False ]
        ]


canSweepTests : Test
canSweepTests =
    describe "Bottle.canSweep"
        [ test "an empty bottle has nothing to sweep" <|
            \_ ->
                Bottle.canSweep emptyBottle
                    |> Expect.equal False
        , test "three in a row is not enough to sweep" <|
            \_ ->
                Bottle.canSweep (withPills (row 16 [ 1, 2, 3 ] Red) emptyBottle)
                    |> Expect.equal False
        , test "four in a row can be swept" <|
            \_ ->
                Bottle.canSweep (withPills (row 16 [ 1, 2, 3, 4 ] Red) emptyBottle)
                    |> Expect.equal True
        ]


isAvailableTests : Test
isAvailableTests =
    describe "Bottle.isAvailable"
        [ test "a fresh pill fits in an empty bottle" <|
            \_ ->
                Bottle.isAvailable (Pill.fromColors ( Red, Blue )) emptyBottle
                    |> Expect.equal True
        , test "a horizontal pill fits when its right half lands on the last column" <|
            \_ ->
                Bottle.isAvailable (pillAt (Horizontal ( Red, Blue )) ( 7, 5 )) emptyBottle
                    |> Expect.equal True
        , test "a horizontal pill may not hang off the right wall" <|
            \_ ->
                Bottle.isAvailable (pillAt (Horizontal ( Red, Blue )) ( 8, 5 )) emptyBottle
                    |> Expect.equal False
        , test "a vertical pill fits against the right wall" <|
            \_ ->
                Bottle.isAvailable (pillAt (Vertical ( Red, Blue )) ( 8, 5 )) emptyBottle
                    |> Expect.equal True
        , test "rotating a vertical pill flat against the right wall is not available" <|
            \_ ->
                -- Env handles the wall kick after this in-place check fails
                Bottle.isAvailable
                    (Pill.turnRight (pillAt (Vertical ( Red, Blue )) ( 8, 5 )))
                    emptyBottle
                    |> Expect.equal False
        , test "rotating one column in from the right wall is available" <|
            \_ ->
                Bottle.isAvailable
                    (Pill.turnRight (pillAt (Horizontal ( Red, Blue )) ( 7, 5 )))
                    emptyBottle
                    |> Expect.equal True
        , test "a pill may not pass the left wall" <|
            \_ ->
                Bottle.isAvailable (pillAt (Horizontal ( Red, Blue )) ( 0, 5 )) emptyBottle
                    |> Expect.equal False
        , test "a pill fits on the bottom row" <|
            \_ ->
                Bottle.isAvailable (pillAt (Horizontal ( Red, Blue )) ( 4, 15 )) emptyBottle
                    |> Expect.equal True
        , test "a pill may not pass the floor" <|
            \_ ->
                Bottle.isAvailable (pillAt (Horizontal ( Red, Blue )) ( 4, 16 )) emptyBottle
                    |> Expect.equal False
        , test "a pill may not overlap an occupied cell" <|
            \_ ->
                let
                    -- a fresh pill covers (4,1) and (5,1)
                    bottle =
                        withPills [ ( ( 5, 1 ), Yellow ) ] emptyBottle
                in
                Bottle.isAvailable (Pill.fromColors ( Red, Blue )) bottle
                    |> Expect.equal False
        ]


canFallTests : Test
canFallTests =
    describe "Bottle.canFall"
        [ test "a pill with empty space beneath it can fall" <|
            \_ ->
                Bottle.canFall ( 1, 14 ) (withPills [ ( ( 1, 14 ), Red ) ] emptyBottle)
                    |> Expect.equal True
        , test "a pill on the floor cannot fall" <|
            \_ ->
                Bottle.canFall ( 1, 16 ) (withPills [ ( ( 1, 16 ), Red ) ] emptyBottle)
                    |> Expect.equal False
        , test "a pill resting on a virus cannot fall" <|
            \_ ->
                let
                    bottle =
                        emptyBottle
                            |> withPills [ ( ( 1, 15 ), Red ) ]
                            |> withViruses [ ( ( 1, 16 ), Blue ) ]
                in
                Bottle.canFall ( 1, 15 ) bottle
                    |> Expect.equal False
        , test "a virus never falls" <|
            \_ ->
                Bottle.canFall ( 1, 14 ) (withViruses [ ( ( 1, 14 ), Blue ) ] emptyBottle)
                    |> Expect.equal False
        , test "an empty cell cannot fall" <|
            \_ ->
                Bottle.canFall ( 3, 3 ) emptyBottle
                    |> Expect.equal False
        , test "both halves of a horizontal pill can fall together" <|
            \_ ->
                let
                    bottle =
                        emptyBottle
                            |> withHalf ( 1, 14 ) Red Right
                            |> withHalf ( 2, 14 ) Blue Left
                in
                List.map (\coords -> Bottle.canFall coords bottle)
                    [ ( 1, 14 ), ( 2, 14 ) ]
                    |> Expect.equal [ True, True ]
        , test "neither half falls when one of them is blocked" <|
            \_ ->
                let
                    bottle =
                        emptyBottle
                            |> withHalf ( 1, 14 ) Red Right
                            |> withHalf ( 2, 14 ) Blue Left
                            |> withViruses [ ( ( 2, 15 ), Yellow ) ]
                in
                List.map (\coords -> Bottle.canFall coords bottle)
                    [ ( 1, 14 ), ( 2, 14 ) ]
                    |> Expect.equal [ False, False ]
        ]


fallTests : Test
fallTests =
    describe "Bottle.fall"
        [ test "an empty bottle is left alone" <|
            \_ ->
                Bottle.fall emptyBottle
                    |> Expect.equal emptyBottle
        , test "stacked singles fall one row at a time over a gap" <|
            \_ ->
                let
                    bottle =
                        withPills
                            [ ( ( 1, 13 ), Red ), ( ( 1, 14 ), Blue ) ]
                            emptyBottle
                in
                statesAt
                    [ ( 1, 13 ), ( 1, 14 ), ( 1, 15 ), ( 1, 16 ) ]
                    (Bottle.fall bottle)
                    |> Expect.equal
                        [ Nothing
                        , Just ( Red, Bottle.Pill Nothing )
                        , Just ( Blue, Bottle.Pill Nothing )
                        , Nothing
                        ]
        , test "stacked singles keep their order once they land" <|
            \_ ->
                let
                    bottle =
                        withPills
                            [ ( ( 1, 13 ), Red ), ( ( 1, 14 ), Blue ) ]
                            emptyBottle
                in
                statesAt
                    [ ( 1, 13 ), ( 1, 14 ), ( 1, 15 ), ( 1, 16 ) ]
                    (applyTimes 3 Bottle.fall bottle)
                    |> Expect.equal
                        [ Nothing
                        , Nothing
                        , Just ( Red, Bottle.Pill Nothing )
                        , Just ( Blue, Bottle.Pill Nothing )
                        ]
        , test "a landed stack does not move again" <|
            \_ ->
                let
                    landed =
                        applyTimes 3
                            Bottle.fall
                            (withPills
                                [ ( ( 1, 13 ), Red ), ( ( 1, 14 ), Blue ) ]
                                emptyBottle
                            )
                in
                Bottle.fall landed
                    |> Expect.equal landed
        , test "a horizontal pill falls as one piece" <|
            \_ ->
                let
                    bottle =
                        emptyBottle
                            |> withHalf ( 1, 14 ) Red Right
                            |> withHalf ( 2, 14 ) Blue Left
                in
                statesAt
                    [ ( 1, 14 ), ( 2, 14 ), ( 1, 15 ), ( 2, 15 ) ]
                    (Bottle.fall bottle)
                    |> Expect.equal
                        [ Nothing
                        , Nothing
                        , Just ( Red, Bottle.Pill (Just Right) )
                        , Just ( Blue, Bottle.Pill (Just Left) )
                        ]
        , test "a horizontal pill stays put when one half is blocked" <|
            \_ ->
                let
                    bottle =
                        emptyBottle
                            |> withHalf ( 1, 14 ) Red Right
                            |> withHalf ( 2, 14 ) Blue Left
                            |> withViruses [ ( ( 2, 15 ), Yellow ) ]
                in
                Bottle.fall bottle
                    |> Expect.equal bottle
        , test "a floating virus stays floating" <|
            \_ ->
                let
                    bottle =
                        withViruses [ ( ( 1, 14 ), Blue ) ] emptyBottle
                in
                Bottle.fall bottle
                    |> Expect.equal bottle
        ]


addPillTests : Test
addPillTests =
    describe "Bottle.addPill"
        [ test "a horizontal pill lands in two neighboring columns" <|
            \_ ->
                statesAt
                    [ ( 4, 1 ), ( 5, 1 ) ]
                    (Bottle.addPill (Pill.fromColors ( Red, Blue )) emptyBottle)
                    |> Expect.equal
                        [ Just ( Red, Bottle.Pill (Just Right) )
                        , Just ( Blue, Bottle.Pill (Just Left) )
                        ]
        , test "a vertical pill lands in two stacked rows" <|
            \_ ->
                statesAt
                    [ ( 4, 5 ), ( 4, 6 ) ]
                    (Bottle.addPill (pillAt (Vertical ( Red, Blue )) ( 4, 5 )) emptyBottle)
                    |> Expect.equal
                        [ Just ( Red, Bottle.Pill (Just Down) )
                        , Just ( Blue, Bottle.Pill (Just Up) )
                        ]
        ]


miscTests : Test
miscTests =
    describe "Bottle helpers"
        [ test "totalViruses counts only viruses" <|
            \_ ->
                emptyBottle
                    |> withViruses [ ( ( 1, 16 ), Red ), ( ( 2, 16 ), Blue ) ]
                    |> withPills [ ( ( 3, 16 ), Yellow ) ]
                    |> Bottle.totalViruses
                    |> Expect.equal 2
        , test "an empty bottle has no viruses" <|
            \_ ->
                Bottle.totalViruses emptyBottle
                    |> Expect.equal 0
        , test "coordsWithDirection steps one cell at a time" <|
            \_ ->
                List.map (\direction -> Bottle.coordsWithDirection direction ( 3, 4 ))
                    [ Up, Down, Left, Right ]
                    |> Expect.equal [ ( 3, 3 ), ( 3, 5 ), ( 2, 4 ), ( 4, 4 ) ]
        , test "getColor cycles through the three colors" <|
            \_ ->
                List.map Bottle.getColor [ 0, 1, 2, 3 ]
                    |> Expect.equal [ Red, Blue, Yellow, Red ]
        ]
