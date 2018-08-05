module Controls exposing (..)

import Bottle exposing (Direction(..))


arrows : Int -> Maybe Direction
arrows keyCode =
    case keyCode of
        38 ->
            Just Up

        37 ->
            Just Left

        39 ->
            Just Right

        40 ->
            Just Down

        _ ->
            Nothing


wasd : Int -> Maybe Direction
wasd keyCode =
    case keyCode of
        87 ->
            Just Up

        65 ->
            Just Left

        68 ->
            Just Right

        83 ->
            Just Down

        _ ->
            Nothing
