module RandomExtra exposing (selectWithDefault)

import Random exposing (Generator)


selectWithDefault : a -> List a -> Generator a
selectWithDefault defaultValue options =
    let
        get : Int -> List a -> Maybe a
        get index list =
            if index < 0 then
                Nothing
            else
                case List.drop index list of
                    [] ->
                        Nothing

                    x :: xs ->
                        Just x

        select : List a -> Generator (Maybe a)
        select list =
            Random.map (\index -> get index list)
                (Random.int 0 (List.length list - 1))
    in
        Random.map (Maybe.withDefault defaultValue) (select options)
