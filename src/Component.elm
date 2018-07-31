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


raiseOutMsg :
    (msg2 -> model2 -> ( model2, Cmd msg2, Maybe msg3 ))
    -> (model1 -> model2)
    -> (msg1 -> msg2)
    -> ( model1, Cmd msg1, Maybe msg2 )
    -> ( model2, Cmd msg2, Maybe msg3 )
raiseOutMsg update toModel toMsg result =
    case result of
        ( state, cmd, Nothing ) ->
            ( toModel state, Cmd.map toMsg cmd, Nothing )

        ( model_, cmd1, Just msg2 ) ->
            let
                ( model__, cmd2, msg3 ) =
                    update msg2 (toModel model_)
            in
                ( model__, Cmd.batch [ Cmd.map toMsg cmd1, cmd2 ], msg3 )
