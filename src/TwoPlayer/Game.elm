module TwoPlayer.Game exposing
    ( GameType(..)
    , Model(..)
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Component
import Element exposing (Element, none, styled)
import Env
import Html exposing (Html, div, h3, p, span, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import MatchupCreator
    exposing
        ( Matchup
        , Opponent(..)
        , Player
        , Position(..)
        , mapEnv
        , mapPlayer
        )
import Pill exposing (Color(..))
import Speed exposing (Speed(..))
import Time


type Model
    = Prepare MatchupCreator.Model
    | Countdown Int Matchup
    | Playing Matchup
    | Paused Matchup
    | Over
        { winner : Position
        , game : Matchup
        }


type Msg
    = EnvMsg EnvMsg
    | CreatorMsg MatchupCreator.Msg
    | MatchupReady Matchup
    | Tick
    | Bomb Position (List Color)
    | Pause
    | Resume
    | Reset


type EnvMsg
    = FirstEnvMsg Env.Msg
    | SecondEnvMsg Env.Msg


type alias Options =
    { level : Int
    , speed : Speed
    }


type GameType
    = VsHuman
    | VsBot


init : GameType -> Options -> Options -> ( Model, Cmd Msg )
init type_ first second =
    let
        opponent =
            case type_ of
                VsHuman ->
                    Human

                VsBot ->
                    Bot

        ( creator, cmd ) =
            MatchupCreator.init opponent first second
    in
    ( Prepare creator
    , Cmd.map CreatorMsg cmd
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Countdown _ _ ->
            Time.every 1000 (\_ -> Tick)

        Playing { first, second } ->
            Sub.batch
                [ Env.subscriptions first.speed first.env
                    |> Sub.map (FirstEnvMsg >> EnvMsg)
                , Env.subscriptions second.speed second.env
                    |> Sub.map (SecondEnvMsg >> EnvMsg)
                ]

        _ ->
            Sub.none



-- UPDATE --


update : { onLeave : msg } -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update { onLeave } action model =
    let
        withNothing s =
            ( s, Cmd.none, Nothing )
    in
    case ( model, action ) of
        ( Prepare creator, CreatorMsg msg ) ->
            MatchupCreator.update { onCreated = MatchupReady } msg creator
                |> Component.raiseOutMsg (update { onLeave = onLeave })
                    Prepare
                    CreatorMsg

        ( Prepare _, MatchupReady matchup ) ->
            Countdown 3 matchup |> withNothing

        ( Prepare _, _ ) ->
            model |> withNothing

        ( Countdown seconds matchup, Tick ) ->
            let
                remaining =
                    seconds - 1
            in
            if remaining > 0 then
                Countdown remaining matchup |> withNothing

            else
                Playing matchup |> withNothing

        ( Countdown seconds matchup, _ ) ->
            model |> withNothing

        ( Playing state, Pause ) ->
            Paused state |> withNothing

        ( Paused state, Resume ) ->
            Playing state |> withNothing

        ( Paused _, _ ) ->
            model |> withNothing

        ( Playing state, Bomb receiver colors ) ->
            ( Playing <|
                mapPlayer receiver
                    (mapEnv (Env.withBombs colors))
                    state
            , Cmd.none
            , Nothing
            )

        ( Playing state, EnvMsg msg ) ->
            case getWinner state of
                Just winner ->
                    withNothing <|
                        Over
                            { winner = winner
                            , game = state
                            }

                Nothing ->
                    updatePlayState onLeave msg state

        ( Playing _, _ ) ->
            model |> withNothing

        ( Over _, Reset ) ->
            ( model, Cmd.none, Just onLeave )

        ( Over _, _ ) ->
            model |> withNothing


getWinner : Matchup -> Maybe Position
getWinner { first, second } =
    if Env.totalViruses first.env == 0 || Env.hasConflict second.env then
        Just First

    else if Env.totalViruses second.env == 0 || Env.hasConflict first.env then
        Just Second

    else
        Nothing


updatePlayState : msg -> EnvMsg -> Matchup -> ( Model, Cmd Msg, Maybe msg )
updatePlayState onLeave action ({ first, second } as model) =
    case action of
        FirstEnvMsg msg ->
            Env.update { onBomb = Bomb Second >> Just } msg first.env
                |> Component.raiseOutMsg (update { onLeave = onLeave })
                    (\env ->
                        Playing
                            { model | first = mapEnv (\_ -> env) first }
                    )
                    (FirstEnvMsg >> EnvMsg)

        SecondEnvMsg msg ->
            Env.update { onBomb = Bomb First >> Just } msg second.env
                |> Component.raiseOutMsg (update { onLeave = onLeave })
                    (\env ->
                        Playing
                            { model | second = mapEnv (\_ -> env) second }
                    )
                    (SecondEnvMsg >> EnvMsg)



-- VIEW --


view : Model -> Html Msg
view model =
    case model of
        Prepare _ ->
            div [] [ text "💊💊💊" ]

        Countdown seconds { first, second } ->
            viewArena first second Nothing <|
                h3 [ style "text-align" "center", style "font-size" "64px" ]
                    [ text (String.fromInt seconds) ]

        Playing { first, second } ->
            viewArena first second Nothing <|
                Html.button [ onClick Pause ] [ text "Pause" ]

        Paused _ ->
            viewMessage "Paused" <|
                Html.button
                    [ onClick Resume ]
                    [ text "resume" ]

        Over state ->
            div [ style "position" "relative" ]
                [ viewMessage
                    (case state.winner of
                        First ->
                            "1p wins"

                        Second ->
                            "2p wins"
                    )
                    (div [] [ Html.button [ onClick Reset ] [ text "Main Menu" ] ])
                , viewArena state.game.first state.game.second (Just state.winner) none
                ]


viewArena : Player -> Player -> Maybe Position -> Html Msg -> Html Msg
viewArena first second winner extra =
    let
        isWinner pos_ =
            winner
                |> Maybe.map (\pos -> pos == pos_)
                |> Maybe.withDefault False
    in
    div
        [ style "display" "flex"
        , style "flex-direction" "row"
        ]
        [ viewPlayer first (isWinner First)
        , div [ style "margin" "0 12px" ]
            -- TODO: displays win count
            [ h3 [] [ text "level" ]
            , spaceBetween []
                [ span [] [ (String.fromInt >> text) first.level ]
                , span [] [ (String.fromInt >> text) second.level ]
                ]
            , h3 [] [ text "speed" ]
            , spaceBetween []
                [ span [] [ (Speed.toString >> text) first.speed ]
                , span [] [ (Speed.toString >> text) second.speed ]
                ]
            , h3 [] [ text "virus" ]
            , spaceBetween []
                [ span [] [ text <| displayViruses first ]
                , span [] [ text <| displayViruses second ]
                ]
            , extra
            ]
        , viewPlayer second (isWinner Second)
        ]


displayViruses : Player -> String
displayViruses player =
    String.fromInt (Env.totalViruses player.env)


viewPlayer : Player -> Bool -> Html msg
viewPlayer { env } isWinner =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "align-items" "center"
        , style "position" "relative"
        ]
        [ div [ style "display" "flex", style "margin-bottom" "18px" ]
            (Env.viewPill env.next)
        , Env.view env
        , if isWinner then
            div
                [ style "position" "absolute"
                , style "top" "50%"
                , style "transform" "translateY(-50%)"
                , style "font-size" "6rem"
                ]
                [ h3 [] [ text "🏆" ] ]

          else
            none
        ]


spaceBetween : Element msg
spaceBetween =
    styled p [ ( "display", "flex" ), ( "justify-content", "space-between" ) ]


viewMessage : String -> Html msg -> Html msg
viewMessage message below =
    div
        [ style "text-align" "center"
        , style "margin" "16px 0"
        , style "position" "absolute"
        , style "z-index" "100"
        , style "background" "#ffffffe8"
        , style "padding" "18px"
        , style "left" "50%"
        , style "top" "50%"
        , style "transform" "translate(-50%, -50%)"
        , style "border-radius" "4px"
        ]
        [ h3 [] [ text message ]
        , below
        ]
