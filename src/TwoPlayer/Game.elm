module TwoPlayer.Game exposing
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
import Html exposing (Html, div, h3, p, span, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import LevelCreator


type alias Player =
    { bottle : Bottle.Model
    , level : Int
    , speed : Speed
    }


withBottle : Bottle.Model -> Player -> Player
withBottle newBottle player =
    { player | bottle = newBottle }


type alias State =
    { first : Player
    , second : Player
    }


type Winner
    = First
    | Second


type Model
    = PrepareFirst State LevelCreator.Model
    | PrepareSecond State LevelCreator.Model
    | Playing State
    | Paused State
    | Over
        { winner : Winner
        , game : State
        }


type Msg
    = FirstBottleMsg Bottle.Msg
    | SecondBottleMsg Bottle.Msg
    | CreatorMsg LevelCreator.Msg
    | LevelReady State
    | FirstBomb (List Color)
    | SecondBomb (List Color)
    | Pause
    | Resume
    | Reset


type alias Options =
    { level : Int
    , speed : Speed
    }


init : Options -> Options -> ( Model, Cmd Msg )
init first second =
    let
        ( creator, cmd ) =
            LevelCreator.init first.level

        withOpts : Options -> Player
        withOpts opts =
            { level = opts.level
            , speed = opts.speed
            , bottle = Bottle.init
            }
    in
    ( PrepareFirst
        { first = withOpts first
        , second = withOpts second
        }
        creator
    , Cmd.map CreatorMsg cmd
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Playing { first, second } ->
            Sub.batch
                [ Bottle.subscriptions first.speed first.bottle
                    |> Sub.map FirstBottleMsg
                , Bottle.subscriptions second.speed second.bottle
                    |> Sub.map SecondBottleMsg
                ]

        _ ->
            Sub.none



-- UPDATE --


update : { onLeave : msg } -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update { onLeave } action model =
    case ( model, action ) of
        ( PrepareFirst state creator, CreatorMsg msg ) ->
            let
                first =
                    state.first

                ( creator_, cmd, maybeMsg ) =
                    LevelCreator.update
                        { onCreated =
                            \{ bottle } ->
                                LevelReady
                                    { state | first = { first | bottle = bottle } }
                        }
                        msg
                        creator
            in
            case maybeMsg of
                Nothing ->
                    ( PrepareFirst state creator_
                    , Cmd.map CreatorMsg cmd
                    , Nothing
                    )

                Just msg2 ->
                    update { onLeave = onLeave }
                        msg2
                        (PrepareFirst state creator_)

        ( PrepareFirst _ _, LevelReady state ) ->
            let
                ( creator_, cmd ) =
                    LevelCreator.init state.second.level

                first =
                    state.first

                state_ =
                    { state | first = { first | bottle = Bottle.withControls Controls.wasd state.first.bottle } }
            in
            ( PrepareSecond state_ creator_
            , Cmd.map CreatorMsg cmd
            , Nothing
            )

        ( PrepareFirst _ _, _ ) ->
            ( model, Cmd.none, Nothing )

        ( PrepareSecond state creator, CreatorMsg msg ) ->
            let
                second =
                    state.second

                ( creator_, cmd, maybeMsg ) =
                    LevelCreator.update
                        { onCreated =
                            \{ bottle } ->
                                LevelReady
                                    { state | second = { second | bottle = Bottle.withControls Controls.arrows bottle } }
                        }
                        msg
                        creator
            in
            if state.first.level == state.second.level then
                ( Playing
                    { state | second = { second | bottle = Bottle.withControls Controls.arrows state.first.bottle } }
                , Cmd.none
                , Nothing
                )

            else
                case maybeMsg of
                    Nothing ->
                        ( PrepareSecond state creator_
                        , Cmd.map CreatorMsg cmd
                        , Nothing
                        )

                    Just msg2 ->
                        update { onLeave = onLeave }
                            msg2
                            (PrepareSecond state creator_)

        ( PrepareSecond _ _, LevelReady state ) ->
            ( Playing state, Cmd.none, Nothing )

        ( PrepareSecond _ _, _ ) ->
            ( model, Cmd.none, Nothing )

        ( Playing state, Pause ) ->
            ( Paused state, Cmd.none, Nothing )

        ( Paused state, Resume ) ->
            ( Playing state, Cmd.none, Nothing )

        ( Paused _, _ ) ->
            ( model, Cmd.none, Nothing )

        ( Playing state, FirstBomb colors ) ->
            ( Playing
                { state
                    | second =
                        state.second
                            |> withBottle (Bottle.withBombs colors state.second.bottle)
                }
            , Cmd.none
            , Nothing
            )

        ( Playing state, SecondBomb colors ) ->
            ( Playing
                { state
                    | first =
                        state.first
                            |> withBottle (Bottle.withBombs colors state.first.bottle)
                }
            , Cmd.none
            , Nothing
            )

        ( Playing ({ first, second } as state), msg ) ->
            if Bottle.totalViruses first.bottle.contents == 0 || Bottle.hasConflict second.bottle then
                ( Over
                    { winner = First
                    , game = state
                    }
                , Cmd.none
                , Nothing
                )

            else if Bottle.totalViruses second.bottle.contents == 0 || Bottle.hasConflict first.bottle then
                ( Over
                    { winner = Second
                    , game = state
                    }
                , Cmd.none
                , Nothing
                )

            else
                updatePlayState onLeave msg state

        ( Over _, Reset ) ->
            ( model, Cmd.none, Just onLeave )

        ( Over _, _ ) ->
            ( model, Cmd.none, Nothing )


updatePlayState : msg -> Msg -> State -> ( Model, Cmd Msg, Maybe msg )
updatePlayState onLeave action ({ first, second } as model) =
    case action of
        FirstBottleMsg msg ->
            Bottle.update { onBomb = FirstBomb >> Just } msg first.bottle
                |> Component.raiseOutMsg (update { onLeave = onLeave })
                    (\bottle ->
                        Playing
                            { model | first = withBottle bottle first }
                    )
                    FirstBottleMsg

        SecondBottleMsg msg ->
            Bottle.update { onBomb = SecondBomb >> Just } msg second.bottle
                |> Component.raiseOutMsg (update { onLeave = onLeave })
                    (\bottle ->
                        Playing
                            { model | second = withBottle bottle second }
                    )
                    SecondBottleMsg

        _ ->
            -- TODO: get rid of this
            ( Playing model, Cmd.none, Nothing )



-- VIEW --


view : Model -> Html Msg
view model =
    case model of
        PrepareFirst _ _ ->
            div [] [ text "💊💊💊" ]

        PrepareSecond _ _ ->
            div [] [ text "💊💊💊" ]

        Playing state ->
            div []
                [ div
                    [ style "display" "flex"
                    , style "flex-direction" "row"
                    ]
                    [ viewPlayer state.first
                    , div [ style "margin" "0 12px" ]
                        -- TODO: displays win count
                        [ h3 [] [ text "level" ]
                        , spaceBetween []
                            [ span [] [ (String.fromInt >> text) state.first.level ]
                            , span [] [ (String.fromInt >> text) state.second.level ]
                            ]
                        , h3 [] [ text "speed" ]
                        , spaceBetween []
                            [ span [] [ (Bottle.speedToString >> text) state.first.speed ]
                            , span [] [ (Bottle.speedToString >> text) state.second.speed ]
                            ]
                        , h3 [] [ text "virus" ]
                        , spaceBetween []
                            [ span [] [ text <| displayViruses state.first ]
                            , span [] [ text <| displayViruses state.second ]
                            ]
                        ]
                    , viewPlayer state.second
                    ]
                ]

        Paused _ ->
            div []
                [ viewMessage "Paused" <|
                    Html.button
                        [ onClick Resume ]
                        [ text "resume" ]
                ]

        Over state ->
            div []
                -- TODO: make it obvious which bottle won
                [ viewMessage
                    (case state.winner of
                        First ->
                            "1p wins"

                        Second ->
                            "2p wins"
                    )
                    (div [] [ Html.button [ onClick Reset ] [ text "Main Menu" ] ])
                , view (Playing state.game)
                ]


displayViruses : Player -> String
displayViruses player =
    String.fromInt (Bottle.totalViruses player.bottle.contents)


viewPlayer : Player -> Html msg
viewPlayer { bottle } =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "align-items" "center"
        ]
        [ div [ style "display" "flex", style "margin-bottom" "18px" ]
            [ (Tuple.first >> Bottle.viewPill (Just Bottle.Right)) bottle.next
            , (Tuple.second >> Bottle.viewPill (Just Bottle.Left)) bottle.next
            ]
        , Bottle.view bottle
        ]


spaceBetween : Element msg
spaceBetween =
    styled p [ ( "display", "flex" ), ( "justify-content", "space-between" ) ]


viewMessage : String -> Html msg -> Html msg
viewMessage message below =
    div [ style "text-align" "center", style "margin" "16px 0" ]
        [ h3 [] [ text message ]
        , below
        ]
