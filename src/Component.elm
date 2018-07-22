module Component exposing (..)


mapOutMsg :
    (msg2 -> model2 -> ( model2, Cmd msg2 ))
    -> (model1 -> model2)
    -> (msg1 -> msg2)
    -> ( model1, Cmd msg1, Maybe msg2 )
    -> ( model2, Cmd msg2 )
mapOutMsg update toModel toMsg result =
    case result of
        ( state, cmd, Nothing ) ->
            ( toModel state, Cmd.map toMsg cmd )

        ( newModel, cmd1, Just msg ) ->
            update msg (toModel newModel)
                |> Tuple.mapSecond
                    (\cmd2 -> Cmd.batch [ Cmd.map toMsg cmd1, cmd2 ])


mapSimple :
    (msg2 -> model2 -> ( model2, Cmd msg2 ))
    -> (model1 -> model2)
    -> (msg1 -> msg2)
    -> ( model1, Cmd msg1 )
    -> ( model2, Cmd msg2 )
mapSimple update toModel toMsg result =
    let
        ( state, cmd ) =
            result
    in
        ( toModel state, Cmd.map toMsg cmd )
