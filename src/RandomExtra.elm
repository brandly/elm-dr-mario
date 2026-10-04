module RandomExtra exposing (select)

import Random exposing (Generator)


{-| Pick one of the options at random, or `Nothing` when there are none.
-}
select : List a -> Generator (Maybe a)
select options =
    case options of
        first :: rest ->
            Random.map Just (Random.uniform first rest)

        [] ->
            Random.constant Nothing
