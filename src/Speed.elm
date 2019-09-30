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
