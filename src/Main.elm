module Main exposing (..)

import Html exposing (Html, h1, h3, text, div, p)
import Html.Attributes exposing (style, type_)
import Html.Events exposing (onClick)
import Grid
import Time exposing (Time, second)
import Random exposing (Generator)
import Menu
import Game exposing (Color(..))
import Element exposing (none)


main : Program Never Model Msg
main =
    Html.program
        { init = ( Init Menu.init, Cmd.none )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Model
    = Init Menu.State
    | PrepareGame
        { level : Int
        , score : Int
        , bottle : Game.Bottle
        , speed : Game.Speed
        }
    | Playing Game.State
    | Paused Game.State
    | Over
        { won : Bool
        , game : Game.State
        }


type Msg
    = Begin
        { level : Int
        , score : Int
        , speed : Game.Speed
        }
    | NewVirus ( Color, Grid.Coords )
    | InitPill ( Color, Color )
    | MenuMsg Menu.Msg
    | PlayMsg Game.Msg
    | Pause
    | Resume
    | Reset


randomNewVirus : Game.Bottle -> Cmd Msg
randomNewVirus bottle =
    Random.generate NewVirus <|
        Random.pair Game.generateColor (Game.generateEmptyCoords bottle)


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case ( model, action ) of
        ( _, Begin { level, score, speed } ) ->
            ( PrepareGame
                { level = level
                , score = score
                , bottle = Game.emptyBottle
                , speed = speed
                }
            , randomNewVirus Game.emptyBottle
            )

        ( PrepareGame ({ level, score, bottle } as state), NewVirus ( color, coords ) ) ->
            let
                newBottle =
                    Grid.setState (( color, Game.Virus )) coords bottle
            in
                if Game.isCleared coords newBottle then
                    -- would create a 4-in-a-row, so let's try a new virus
                    ( PrepareGame state, randomNewVirus bottle )
                else if Game.totalViruses newBottle >= Game.virusesForLevel level then
                    ( PrepareGame { state | bottle = newBottle }
                    , Random.generate InitPill <|
                        Game.generatePill
                    )
                else
                    ( PrepareGame { state | bottle = newBottle }
                    , randomNewVirus newBottle
                    )

        ( PrepareGame { level, bottle, score, speed }, InitPill colors ) ->
            ( (Game.init >> Playing)
                { level = level
                , bottle = bottle
                , score = score
                , colors = colors
                , speed = speed
                }
            , Cmd.none
            )

        ( Playing state, Pause ) ->
            ( Paused state, Cmd.none )

        ( Paused state, Resume ) ->
            ( Playing state, Cmd.none )

        ( Init state, MenuMsg msg ) ->
            state
                |> Menu.update
                    { onSubmit =
                        \menu ->
                            Begin
                                { level = menu.level
                                , speed = menu.speed
                                , score = 0
                                }
                    }
                    msg
                |> mapComponent update Init MenuMsg

        ( Playing state, PlayMsg msg ) ->
            if Game.totalViruses state.bottle == 0 then
                ( Over
                    { won = True
                    , game = state
                    }
                , Cmd.none
                )
            else if Game.isOver state then
                ( Over
                    { won = False
                    , game = state
                    }
                , Cmd.none
                )
            else
                Game.update msg state
                    |> Tuple.mapFirst Playing
                    |> Tuple.mapSecond (Cmd.map PlayMsg)

        ( Over _, Reset ) ->
            ( Init Menu.init, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


mapComponent :
    (msg2 -> model2 -> ( model2, Cmd msg2 ))
    -> (model1 -> model2)
    -> (msg1 -> msg2)
    -> { result : ( model1, Cmd msg1 ), event : Maybe msg2 }
    -> ( model2, Cmd msg2 )
mapComponent update toModel toMsg { result, event } =
    case ( result, event ) of
        ( _, Nothing ) ->
            result
                |> Tuple.mapFirst toModel
                |> Tuple.mapSecond (Cmd.map toMsg)

        ( ( newModel, cmd1 ), Just msg ) ->
            update msg (toModel newModel)
                |> Tuple.mapSecond
                    (\cmd2 -> Cmd.batch [ Cmd.map toMsg cmd1, cmd2 ])


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Init state ->
            Sub.map MenuMsg <| Menu.subscriptions state

        Playing state ->
            Sub.map PlayMsg <| Game.subscriptions state

        _ ->
            Sub.none


view : Model -> Html Msg
view model =
    div [ style [ ( "display", "flex" ), ( "flex-direction", "column" ), ( "align-items", "center" ) ] ]
        [ h1 [] [ text "dr. mario 💊" ]
        , case model of
            Init state ->
                Menu.view state

            PrepareGame _ ->
                div [] [ text "💊💊💊" ]

            Playing state ->
                Game.view (Just Pause) state

            Paused state ->
                div []
                    [ viewMessage "Paused"
                        (Html.button
                            [ onClick Resume ]
                            [ text "resume" ]
                        )
                    ]

            Over state ->
                div []
                    [ viewMessage
                        (if state.won then
                            "You Win!"
                         else
                            "Game Over"
                        )
                        (div []
                            [ (if state.won then
                                Html.button
                                    [ onClick
                                        (Begin
                                            { speed = state.game.speed
                                            , level = (state.game.level + 1)
                                            , score = state.game.score
                                            }
                                        )
                                    ]
                                    [ text "Next Level" ]
                               else
                                none
                              )
                            , Html.button [ onClick Reset ] [ text "Main Menu" ]
                            ]
                        )
                    , Game.view Nothing state.game
                    ]
        ]


viewMessage : String -> Html msg -> Html msg
viewMessage message below =
    div [ style [ ( "text-align", "center" ), ( "margin", "16px 0" ) ] ]
        [ h3 [] [ text message ]
        , below
        ]
