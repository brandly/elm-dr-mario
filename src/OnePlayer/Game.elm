module OnePlayer.Game exposing
    ( Model(..)
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Bottle exposing (Color(..), Speed(..))
import Component
import Controls
import Element exposing (Element, none, styled)
import Html exposing (Html, div, h3, p, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import LevelCreator


type alias State =
    { bottle : Bottle.Model
    , level : Int
    , score : Int
    , speed : Speed
    }


type Model
    = PrepareGame
        { score : Int
        , speed : Speed
        , creator : LevelCreator.Model
        }
    | Playing State
    | Paused State
    | Over
        { won : Bool
        , game : State
        }


type Msg
    = BottleMsg Bottle.Msg
    | CreatorMsg LevelCreator.Msg
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
            LevelCreator.init level
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
        Playing { speed, bottle } ->
            Sub.batch
                [ Bottle.subscriptions speed bottle
                    |> Sub.map BottleMsg
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
                    LevelCreator.update
                        { onCreated =
                            \{ level, bottle } ->
                                LevelReady
                                    { bottle = bottle
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
                { state | bottle = Bottle.withControls Controls.arrows state.bottle }
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

        ( Playing state, BottleMsg msg ) ->
            if Bottle.totalViruses state.bottle.contents == 0 then
                ( Over
                    { won = True
                    , game = state
                    }
                , Cmd.none
                , Nothing
                )

            else if Bottle.hasConflict state.bottle then
                ( Over
                    { won = False
                    , game = state
                    }
                , Cmd.none
                , Nothing
                )

            else
                updatePlayState onLeave msg state

        ( Playing state, _ ) ->
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


updatePlayState : msg -> Bottle.Msg -> State -> ( Model, Cmd Msg, Maybe msg )
updatePlayState onLeave action ({ bottle, speed, score } as model) =
    let
        withBottle : Bottle.Model -> Model
        withBottle newBottle =
            let
                sweptViruses =
                    Bottle.totalViruses bottle.contents - Bottle.totalViruses newBottle.contents

                additionalPoints =
                    pointsForClearedViruses speed sweptViruses
            in
            Playing
                { model
                    | bottle = newBottle
                    , score = score + additionalPoints
                }
    in
    Bottle.update { onBomb = \_ -> Nothing } action model.bottle
        |> Component.raiseOutMsg (update { onLeave = onLeave })
            withBottle
            BottleMsg



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
viewPlaying pauseMsg { score, bottle, level, speed } =
    div [ style "display" "flex" ]
        [ columnEl []
            [ h3 [] [ text "score" ]
            , p [ style "text-align" "right" ]
                [ (String.fromInt >> text) score ]
            , pauseMsg
                |> Maybe.map (\msg -> Html.button [ onClick msg ] [ text "pause" ])
                |> Maybe.withDefault none
            ]
        , Bottle.view bottle
        , columnEl []
            [ h3 [] [ text "next" ]
            , div [ style "display" "flex" ]
                -- TODO: there should be a nicer fn that hides the Just Left/Right
                [ (Tuple.first >> Bottle.viewPill (Just Bottle.Right)) bottle.next
                , (Tuple.second >> Bottle.viewPill (Just Bottle.Left)) bottle.next
                ]
            , div [ style "margin" "72px 0" ]
                [ h3 [] [ text "level" ]
                , p [] [ (String.fromInt >> text) level ]
                , h3 [] [ text "speed" ]
                , p [] [ (Bottle.speedToString >> text) speed ]
                , h3 [] [ text "virus" ]
                , p [] [ text <| String.fromInt (Bottle.totalViruses bottle.contents) ]
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
