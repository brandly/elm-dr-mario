module BotTests exposing (suite)

import Bot
import Bottle exposing (Bottle)
import Direction exposing (Direction(..))
import Env
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


withVirus : Grid.Coords -> Color -> Bottle -> Bottle
withVirus coords color bottle =
    Grid.setState ( color, Bottle.Virus ) coords bottle


pillAt : Orientation -> Grid.Coords -> Pill.Pill
pillAt orientation coords =
    { orientation = orientation, coords = coords }


{-| An `Env.Model` sitting in the middle of dropping `pill` into `bottle`.
The pill in flight is not part of the bottle, same as during a real game.
-}
placing : Bottle -> Pill.Pill -> Env.Model
placing bottle pill =
    let
        model =
            Env.init
    in
    { model | bottle = bottle, mode = Env.PlacingPill pill }



-- TESTS


suite : Test
suite =
    describe "Bot"
        [ describe "trashBot"
            [ test "scores a column against its own peak when the column to the left is empty" <|
                \_ ->
                    let
                        -- column 1 is empty all the way down, column 2 is
                        -- topped with red, and column 3 is walled off so the
                        -- pill can only reach columns 1 and 2
                        bottle =
                            emptyBottle
                                |> withVirus ( 2, 10 ) Red
                                |> withVirus ( 3, 5 ) Blue
                    in
                    Bot.trashBot (placing bottle (pillAt (Vertical ( Red, Red )) ( 1, 5 )))
                        |> Expect.equal
                            ( Just Right
                            , Just (pillAt (Vertical ( Red, Red )) ( 2, 0 ))
                            )
            , test "lines both halves of a horizontal pill up with their own colors" <|
                \_ ->
                    let
                        -- columns 1 and 4 are empty, column 2 is topped with
                        -- red, column 3 with blue, and column 5 is walled off
                        bottle =
                            emptyBottle
                                |> withVirus ( 2, 10 ) Red
                                |> withVirus ( 3, 10 ) Blue
                                |> withVirus ( 5, 5 ) Yellow
                    in
                    Bot.trashBot (placing bottle (pillAt (Horizontal ( Red, Blue )) ( 1, 5 )))
                        |> Expect.equal
                            ( Just Right
                            , Just (pillAt (Horizontal ( Red, Blue )) ( 2, 0 ))
                            )
            ]
        ]
