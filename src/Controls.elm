module Controls exposing
    ( arrowDown
    , arrowLeft
    , arrowRight
    , arrowUp
    , arrows
    , enter
    , key
    , wasd
    )

import Direction exposing (Direction(..))
import Json.Decode as Decode


{-| Decodes the `key` of a keyboard event, e.g. "ArrowUp" or "w".

`keyCode` is deprecated, and forces every reader to translate magic numbers.
<https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key>

-}
key : Decode.Decoder String
key =
    Decode.field "key" Decode.string


arrowUp : String
arrowUp =
    "ArrowUp"


arrowLeft : String
arrowLeft =
    "ArrowLeft"


arrowRight : String
arrowRight =
    "ArrowRight"


arrowDown : String
arrowDown =
    "ArrowDown"


enter : String
enter =
    "Enter"


arrows : String -> Maybe Direction
arrows pressed =
    if pressed == arrowUp then
        Just Up

    else if pressed == arrowLeft then
        Just Left

    else if pressed == arrowRight then
        Just Right

    else if pressed == arrowDown then
        Just Down

    else
        Nothing


{-| `key` is case sensitive: shift (or caps lock) reports "W" instead of "w",
so match on the lowercased key.
-}
wasd : String -> Maybe Direction
wasd pressed =
    case String.toLower pressed of
        "w" ->
            Just Up

        "a" ->
            Just Left

        "d" ->
            Just Right

        "s" ->
            Just Down

        _ ->
            Nothing
