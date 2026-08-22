module EnvTests exposing (suite)

import Bottle exposing (Bottle)
import Direction exposing (Direction(..))
import Env
import Expect
import Grid
import Pill exposing (Color(..))
import Test exposing (Test, describe, test)
import Time



-- HELPERS


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


modelWith : Bottle -> Env.Model
modelWith bottle =
    let
        model =
            Env.init
    in
    { model | bottle = bottle }


{-| `Env.sweep` and its `clearedLines` are private, so we reach them the way
the game does: a tick on a settled bottle that has something to clear.
-}
tick : Env.Model -> Env.Model
tick model =
    let
        ( next, _, _ ) =
            Env.update { onBomb = Just }
                (Env.TickTock (Time.millisToPosix 0))
                model
    in
    next


swept : Bottle -> Bottle
swept bottle =
    .bottle (tick (modelWith bottle))


cleared : Bottle -> Env.Mode
cleared bottle =
    .mode (tick (modelWith bottle))


{-| Nothing in the bottle can fall, which is what makes a tick sweep instead
of dropping pills.
-}
isSettled : Bottle -> Bool
isSettled bottle =
    not (Grid.any (\{ coords } -> Bottle.canFall coords bottle) bottle)



-- FIXTURES


{-| One horizontal run along the floor.
-}
singleLine : Bottle
singleLine =
    withPills (row 16 [ 1, 2, 3, 4 ] Red) emptyBottle


{-| An L: a vertical run up column 1 meeting a horizontal run along the
floor. The shared corner (1,16) is the *last* of the two runs' cells in
scan order.
-}
lShape : Bottle
lShape =
    emptyBottle
        |> withPills (column 1 [ 13, 14, 15, 16 ] Red)
        |> withPills (row 16 [ 2, 3, 4 ] Red)


{-| The same L flipped so the shared corner (1,13) comes *first* in scan
order.
-}
lShapeCornerFirst : Bottle
lShapeCornerFirst =
    emptyBottle
        |> withPills (column 1 [ 13, 14, 15, 16 ] Red)
        |> withPills (row 13 [ 2, 3, 4 ] Red)
        -- the arm of the L needs something to rest on. these fillers
        -- alternate colors so they never form a run of their own.
        |> withPills (row 14 [ 2, 4 ] Blue)
        |> withPills (row 14 [ 3 ] Yellow)
        |> withPills (row 15 [ 2, 4 ] Yellow)
        |> withPills (row 15 [ 3 ] Blue)
        |> withPills (row 16 [ 2, 4 ] Blue)
        |> withPills (row 16 [ 3 ] Yellow)


{-| Two separate four-runs sharing the bottom row.
-}
twoRunsInARow : Bottle
twoRunsInARow =
    emptyBottle
        |> withPills (row 16 [ 1, 2, 3, 4 ] Red)
        |> withPills (row 16 [ 5, 6, 7, 8 ] Yellow)


{-| Two runs that share neither a row nor a column.
-}
disjointLines : Bottle
disjointLines =
    emptyBottle
        |> withPills (row 16 [ 1, 2, 3, 4 ] Red)
        |> withPills (column 6 [ 13, 14, 15, 16 ] Yellow)



-- TESTS


suite : Test
suite =
    describe "Env"
        [ fixtureTests
        , sweepTests
        , clearedLineCountTests
        , bombTests
        , hasConflictTests
        ]


{-| Guard rails. If a fixture were to stop being sweepable, or something in
it could fall, a tick would fall instead of sweeping and every sweep test
below would fail for a confusing reason.
-}
fixtureTests : Test
fixtureTests =
    describe "sweep fixtures are settled and sweepable"
        (List.map
            (\( name, bottle ) ->
                test name <|
                    \_ ->
                        ( isSettled bottle, Bottle.canSweep bottle )
                            |> Expect.equal ( True, True )
            )
            [ ( "singleLine", singleLine )
            , ( "lShape", lShape )
            , ( "lShapeCornerFirst", lShapeCornerFirst )
            , ( "twoRunsInARow", twoRunsInARow )
            , ( "disjointLines", disjointLines )
            ]
        )


sweepTests : Test
sweepTests =
    describe "sweeping a settled bottle"
        [ test "a single line is removed from the bottle" <|
            \_ ->
                swept singleLine
                    |> Expect.equal emptyBottle
        , test "both runs of an L are removed" <|
            \_ ->
                swept lShape
                    |> Expect.equal emptyBottle
        , test "both runs sharing a row are removed" <|
            \_ ->
                swept twoRunsInARow
                    |> Expect.equal emptyBottle
        , test "viruses caught in a run are removed" <|
            \_ ->
                let
                    bottle =
                        emptyBottle
                            |> withPills (row 16 [ 1, 2, 3 ] Red)
                            |> withViruses [ ( ( 4, 16 ), Red ) ]
                in
                ( Bottle.totalViruses bottle, Bottle.totalViruses (swept bottle) )
                    |> Expect.equal ( 1, 0 )
        , test "a surviving half forgets the partner it lost" <|
            \_ ->
                let
                    -- (4,16) completes the red run and takes (5,16)'s
                    -- partner with it
                    bottle =
                        emptyBottle
                            |> withPills (row 16 [ 1, 2, 3 ] Red)
                            |> withHalf ( 4, 16 ) Red Right
                            |> withHalf ( 5, 16 ) Blue Left

                    after =
                        swept bottle
                in
                ( stateAt ( 4, 16 ) after, stateAt ( 5, 16 ) after )
                    |> Expect.equal
                        ( Nothing, Just ( Blue, Bottle.Pill Nothing ) )
        , test "nothing is swept when there is no run" <|
            \_ ->
                let
                    bottle =
                        withPills (row 16 [ 1, 2, 3 ] Red) emptyBottle
                in
                swept bottle
                    |> Expect.equal bottle
        ]


clearedLineCountTests : Test
clearedLineCountTests =
    describe "cleared lines reported after a sweep"
        [ test "a single line counts as one" <|
            \_ ->
                cleared singleLine
                    |> Expect.equal (Env.Falling [ Red ])
        , test "an L whose corner comes last counts as two" <|
            \_ ->
                cleared lShape
                    |> Expect.equal (Env.Falling [ Red, Red ])
        , test "two runs in different rows and columns count as two" <|
            \_ ->
                cleared disjointLines
                    |> Expect.equal (Env.Falling [ Red, Yellow ])
        , test "an L whose corner comes first counts as two" <|
            \_ ->
                cleared lShapeCornerFirst
                    |> Expect.equal (Env.Falling [ Red, Red ])
        , test "two runs in the same row count as two" <|
            \_ ->
                cleared twoRunsInARow
                    |> Expect.equal (Env.Falling [ Red, Yellow ])
        ]


bombTests : Test
bombTests =
    describe "combos send bombs on the next pill"
        [ test "more than one cleared line sends bombs" <|
            \_ ->
                let
                    model =
                        modelWith emptyBottle

                    ( _, _, sent ) =
                        Env.update { onBomb = Just }
                            (Env.NewPill ( Red, Blue ))
                            { model | mode = Env.Falling [ Red, Yellow ] }
                in
                sent
                    |> Expect.equal (Just [ Red, Yellow ])
        , test "a single cleared line sends nothing" <|
            \_ ->
                let
                    model =
                        modelWith emptyBottle

                    ( _, _, sent ) =
                        Env.update { onBomb = Just }
                            (Env.NewPill ( Red, Blue ))
                            { model | mode = Env.Falling [ Red ] }
                in
                sent
                    |> Expect.equal Nothing
        ]


hasConflictTests : Test
hasConflictTests =
    describe "Env.hasConflict"
        [ test "a fresh pill in an empty bottle has room" <|
            \_ ->
                let
                    model =
                        modelWith emptyBottle
                in
                Env.hasConflict
                    { model | mode = Env.PlacingPill (Pill.fromColors ( Red, Blue )) }
                    |> Expect.equal False
        , test "a fresh pill lands on an occupied cell" <|
            \_ ->
                let
                    model =
                        modelWith (withPills [ ( ( 5, 1 ), Yellow ) ] emptyBottle)
                in
                Env.hasConflict
                    { model | mode = Env.PlacingPill (Pill.fromColors ( Red, Blue )) }
                    |> Expect.equal True
        , test "a bottle with no pill in play never conflicts" <|
            \_ ->
                Env.hasConflict (modelWith (withPills [ ( ( 5, 1 ), Yellow ) ] emptyBottle))
                    |> Expect.equal False
        ]
