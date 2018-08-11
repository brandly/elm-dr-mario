module OnePlayer.Game exposing (..)

import Html exposing (Html, h1, h3, text, div, p)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Element exposing (Element, px, styled, none)
import Bottle exposing (Bottle, Color(..), Speed(..))
import Component
import LevelCreator
import Controls


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
    if cleared > 0 then
        applyNtimes (cleared - 1)
            ((*) 2)
            (case speed of
                Low ->
                    100

                Med ->
                    200

                High ->
                    300
            )
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
                            (\{ level, bottle } ->
                                LevelReady
                                    { bottle = bottle
                                    , level = level
                                    , score = score
                                    , speed = speed
                                    }
                            )
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

        ( Paused state, _ ) ->
            ( model, Cmd.none, Nothing )

        ( Playing state, msg ) ->
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

        ( Over _, Advance { level, score, speed } ) ->
            let
                ( model, msg ) =
                    initWithScore level speed score
            in
                ( model, msg, Nothing )

        ( Over _, Reset ) ->
            ( model, Cmd.none, Just onLeave )

        ( Over _, _ ) ->
            ( model, Cmd.none, Nothing )


updatePlayState : msg -> Msg -> State -> ( Model, Cmd Msg, Maybe msg )
updatePlayState onLeave action ({ bottle, speed, score } as model) =
    let
        withBottle : Bottle.Model -> Model
        withBottle newBottle =
            let
                sweptViruses =
                    (Bottle.totalViruses bottle.contents) - (Bottle.totalViruses newBottle.contents)

                additionalPoints =
                    pointsForClearedViruses speed sweptViruses
            in
                Playing
                    { model
                        | bottle = newBottle
                        , score = score + additionalPoints
                    }
    in
        case action of
            BottleMsg msg ->
                Bottle.update { onBomb = Nothing } msg model.bottle
                    |> Component.raiseOutMsg (update { onLeave = onLeave })
                        withBottle
                        BottleMsg

            _ ->
                -- TODO: get rid of this
                ( Playing model, Cmd.none, Nothing )



-- VIEW --


view : Model -> Html Msg
view model =
    case model of
        PrepareGame _ ->
            div [] [ text "💊💊💊" ]

        Playing state ->
            viewPlaying (Just Pause) state

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
                                    (Advance
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
                , viewPlaying Nothing state.game
                ]


viewPlaying : Maybe msg -> State -> Html msg
viewPlaying pauseMsg { score, bottle, level, speed } =
    div [ style [ ( "display", "flex" ) ] ]
        [ columnEl []
            [ h3 [] [ text "score" ]
            , p [ style [ ( "text-align", "right" ) ] ]
                [ (toString >> text) score ]
            , pauseMsg
                |> Maybe.map (\msg -> Html.button [ onClick msg ] [ text "pause" ])
                |> Maybe.withDefault none
            ]
        , Bottle.view bottle
        , columnEl []
            [ h3 [] [ text "next" ]
            , div [ style [ ( "display", "flex" ) ] ]
                -- TODO: there should be a nicer fn that hides the Just Left/Right
                [ (Tuple.first >> Bottle.viewPill (Just Bottle.Right)) bottle.next
                , (Tuple.second >> Bottle.viewPill (Just Bottle.Left)) bottle.next
                ]
            , div [ style [ ( "margin", "72px 0" ) ] ]
                [ h3 [] [ text "level" ]
                , p [] [ (toString >> text) level ]
                , h3 [] [ text "speed" ]
                , p [] [ (toString >> text) speed ]
                , h3 [] [ text "virus" ]
                , p [] [ text <| toString (Bottle.totalViruses bottle.contents) ]
                ]
            ]
        ]


columnEl : Element msg
columnEl =
    styled div [ ( "margin", "0 16px" ) ]


viewMessage : String -> Html msg -> Html msg
viewMessage message below =
    div [ style [ ( "text-align", "center" ), ( "margin", "16px 0" ) ] ]
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
