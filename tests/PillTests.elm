module PillTests exposing (suite)

import Expect
import Pill exposing (Color(..), Orientation(..))
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Pill"
        [ describe "coordsPair"
            [ test "a horizontal pill occupies its anchor row" <|
                \_ ->
                    Pill.coordsPair
                        { orientation = Horizontal ( Red, Blue )
                        , coords = ( 4, 5 )
                        }
                        |> Expect.equal [ ( 4, 5 ), ( 5, 5 ) ]
            , test "a vertical pill occupies the row above and its anchor row" <|
                \_ ->
                    Pill.coordsPair
                        { orientation = Vertical ( Red, Blue )
                        , coords = ( 4, 5 )
                        }
                        |> Expect.equal [ ( 4, 4 ), ( 4, 5 ) ]
            ]
        , test "a fresh pill occupies the top row" <|
            \_ ->
                Pill.fromColors ( Red, Blue )
                    |> Pill.coordsPair
                    |> Expect.equal [ ( 4, 1 ), ( 5, 1 ) ]
        ]
