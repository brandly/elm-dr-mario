module OnePlayer.Game exposing
    ( Model(..)
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Component
import Controls
import Element exposing (Element, none, styled)
import Env
import EnvCreator
import Html exposing (Html, div, h3, p, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Speed exposing (Speed(..))


type alias State =
    { env : Env.Model
    , level : Int
    , score : Int
    , speed : Speed
    }


type Model
    = PrepareGame
        { score : Int
        , speed : Speed
        , creator : EnvCreator.Model
        }
    | Playing State
    | Paused State
    | Over
        { won : Bool
        , game : State
        }


type Msg
    = EnvMsg Env.Msg
    | CreatorMsg EnvCreator.Msg
    | LevelReady State
    | Advance
        { level : Int
        , score : Int
        , speed : Speed
        }
    | Pause
    | Resume
    | Reset


init : Int -> Speed -> ( Model, Cmd Msg )
init level speed =
    initWithScore level speed 0


initWithScore : Int -> Speed -> Int -> ( Model, Cmd Msg )
initWithScore level speed score =
    let
        ( creator, cmd ) =
            EnvCreator.init level
    in
    ( PrepareGame
        { creator = creator
        , score = score
        , speed = speed
        }
    , Cmd.map CreatorMsg cmd
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Playing { speed, env } ->
            Sub.batch
                [ Env.subscriptions speed env
                    |> Sub.map EnvMsg
                ]

        _ ->
            Sub.none



-- SETTINGS --


pointsForClearedViruses : Speed -> Int -> Int
pointsForClearedViruses speed cleared =
    let
        start =
            case speed of
                Low ->
                    100

                Med ->
                    200

                High ->
                    300
    in
    if cleared > 0 then
        applyNtimes (cleared - 1) ((*) 2) start

    else
        0



-- UPDATE --


update : { onLeave : msg } -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update { onLeave } action model =
    case ( model, action ) of
        ( PrepareGame ({ score, creator, speed } as state), CreatorMsg msg ) ->
            let
                ( creator_, cmd, maybeMsg ) =
                    EnvCreator.update
                        { onCreated =
                            \{ level, env } ->
                                LevelReady
                                    { env = env
                                    , level = level
                                    , score = score
                                    , speed = speed
                                    }
                        }
                        msg
                        creator
            in
            case maybeMsg of
                Nothing ->
                    ( PrepareGame { state | creator = creator_ }
                    , Cmd.map CreatorMsg cmd
                    , Nothing
                    )

                Just msg2 ->
                    update { onLeave = onLeave }
                        msg2
                        (PrepareGame { state | creator = creator_ })

        ( PrepareGame _, LevelReady state ) ->
            ( Playing
                { state | env = Env.withControls Controls.arrows state.env }
            , Cmd.none
            , Nothing
            )

        ( PrepareGame _, _ ) ->
            ( model, Cmd.none, Nothing )

        ( Playing state, Pause ) ->
            ( Paused state, Cmd.none, Nothing )

        ( Paused state, Resume ) ->
            ( Playing state, Cmd.none, Nothing )

        ( Paused _, _ ) ->
            ( model, Cmd.none, Nothing )

        ( Playing state, EnvMsg msg ) ->
            if Env.totalViruses state.env == 0 then
                ( Over
                    { won = True
                    , game = state
                    }
                , Cmd.none
                , Nothing
                )

            else if Env.hasConflict state.env then
                ( Over
                    { won = False
                    , game = state
                    }
                , Cmd.none
                , Nothing
                )

            else
                updatePlayState onLeave msg state

        ( Playing _, _ ) ->
            ( model, Cmd.none, Nothing )

        ( Over _, Advance { level, score, speed } ) ->
            let
                ( model_, msg ) =
                    initWithScore level speed score
            in
            ( model_, msg, Nothing )

        ( Over _, Reset ) ->
            ( model, Cmd.none, Just onLeave )

        ( Over _, _ ) ->
            ( model, Cmd.none, Nothing )


updatePlayState : msg -> Env.Msg -> State -> ( Model, Cmd Msg, Maybe msg )
updatePlayState onLeave action ({ env, speed, score } as model) =
    let
        withBottle : Env.Model -> Model
        withBottle newEnv =
            let
                sweptViruses =
                    Env.totalViruses env - Env.totalViruses newEnv

                additionalPoints =
                    pointsForClearedViruses speed sweptViruses
            in
            Playing
                { model
                    | env = newEnv
                    , score = score + additionalPoints
                }
    in
    Env.update { onBomb = \_ -> Nothing } action env
        |> Component.raiseOutMsg (update { onLeave = onLeave })
            withBottle
            EnvMsg



-- VIEW --


view : Model -> Html Msg
view model =
    case model of
        PrepareGame _ ->
            div [] [ text "💊💊💊" ]

        Playing state ->
            viewPlaying (Just Pause) state

        Paused _ ->
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
                        [ if state.won then
                            Html.button
                                [ onClick
                                    (Advance
                                        { speed = state.game.speed
                                        , level = state.game.level + 1
                                        , score = state.game.score
                                        }
                                    )
                                ]
                                [ text "Next Level" ]

                          else
                            none
                        , Html.button [ onClick Reset ] [ text "Main Menu" ]
                        ]
                    )
                , viewPlaying Nothing state.game
                ]


viewPlaying : Maybe msg -> State -> Html msg
viewPlaying pauseMsg { score, env, level, speed } =
    div [ style "display" "flex" ]
        [ columnEl []
            [ h3 [] [ text "score" ]
            , p [ style "text-align" "right" ]
                [ (String.fromInt >> text) score ]
            , pauseMsg
                |> Maybe.map (\msg -> Html.button [ onClick msg ] [ text "pause" ])
                |> Maybe.withDefault none
            ]
        , Env.view env
        , columnEl []
            [ h3 [] [ text "next" ]
            , div [ style "display" "flex" ]
                (Env.viewPill env.next)
            , div [ style "margin" "72px 0" ]
                [ h3 [] [ text "level" ]
                , p [] [ (String.fromInt >> text) level ]
                , h3 [] [ text "speed" ]
                , p [] [ (Speed.toString >> text) speed ]
                , h3 [] [ text "virus" ]
                , p [] [ text <| String.fromInt (Env.totalViruses env) ]
                ]
            ]
        ]


columnEl : Element msg
columnEl =
    styled div [ ( "margin", "0 16px" ) ]


viewMessage : String -> Html msg -> Html msg
viewMessage message below =
    div [ style "text-align" "center", style "margin" "16px 0" ]
        [ h3 [] [ text message ]
        , below
        ]



-- UTILS --


applyNtimes : Int -> (a -> a) -> a -> a
applyNtimes n f x =
    if n <= 0 then
        x

    else if n == 1 then
        f x

    else
        f (applyNtimes (n - 1) f x)
