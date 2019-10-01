module Speed exposing (..)


type Speed
    = Low
    | Med
    | High


toString : Speed -> String
toString s =
    case s of
        Low ->
            "Low"

        Med ->
            "Med"

        High ->
            "High"


tick : Speed -> Float
tick speed =
    case speed of
        High ->
            300

        Med ->
            700

        Low ->
            1000
