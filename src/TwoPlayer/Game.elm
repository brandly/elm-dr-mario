module TwoPlayer.Game exposing
    ( Model(..)
    , Msg(..)
    , Opponent(..)
    , init
    , subscriptions
    , update
    , view
    )

import Bot
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


mapBottle : (Bottle.Model -> Bottle.Model) -> Player -> Player
mapBottle map player =
    { player | bottle = map player.bottle }


type Opponent
    = Human
    | Bot


type alias State =
    { first : Player
    , second : Player
    }


type Position
    = First
    | Second


getPlayer : Position -> State -> Player
getPlayer position { first, second } =
    case position of
        First ->
            first

        Second ->
            second


mapPlayer : Position -> (Player -> Player) -> State -> State
mapPlayer position map state =
    case position of
        First ->
            { state | first = map state.first }

        Second ->
            { state | second = map state.second }


type Model
    = PrepareFirst Opponent State LevelCreator.Model
    | PrepareSecond Opponent State LevelCreator.Model
    | Playing State
    | Paused State
    | Over
        { winner : Position
        , game : State
        }


type Msg
    = BottleMsg BottleMsg
    | CreatorMsg LevelCreator.Msg
    | LevelReady State
    | Bomb Position (List Color)
    | Pause
    | Resume
    | Reset


type BottleMsg
    = FirstBottleMsg Bottle.Msg
    | SecondBottleMsg Bottle.Msg


type alias Options =
    { level : Int
    , speed : Speed
    }


init : Opponent -> Options -> Options -> ( Model, Cmd Msg )
init opponent first second =
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
        opponent
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
                    |> Sub.map (FirstBottleMsg >> BottleMsg)
                , Bottle.subscriptions second.speed second.bottle
                    |> Sub.map (SecondBottleMsg >> BottleMsg)
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
        ( PrepareFirst opponent ({ first, second } as state) creator, CreatorMsg msg ) ->
            let
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
                    ( PrepareFirst opponent state creator_
                    , Cmd.map CreatorMsg cmd
                    , Nothing
                    )

                Just msg2 ->
                    update { onLeave = onLeave }
                        msg2
                        (PrepareFirst opponent state creator_)

        ( PrepareFirst opponent _ _, LevelReady state ) ->
            let
                ( creator_, cmd ) =
                    LevelCreator.init state.second.level

                withControls bottle =
                    case opponent of
                        Human ->
                            Bottle.withControls Controls.wasd bottle

                        Bot ->
                            Bottle.withControls Controls.arrows bottle

                state_ =
                    mapPlayer First (mapBottle withControls) state
            in
            ( PrepareSecond opponent state_ creator_
            , Cmd.map CreatorMsg cmd
            , Nothing
            )

        ( PrepareFirst _ _ _, _ ) ->
            model |> withNothing

        ( PrepareSecond opponent ({ first, second } as state) creator, CreatorMsg msg ) ->
            if first.level == second.level then
                update { onLeave = onLeave }
                    -- reuse generated bottle so the game is fair
                    (LevelReady { state | second = { second | bottle = first.bottle } })
                    (PrepareSecond opponent state creator)

            else
                let
                    ( creator_, cmd, maybeMsg ) =
                        LevelCreator.update
                            { onCreated =
                                \{ bottle } ->
                                    LevelReady
                                        { state | second = { second | bottle = bottle } }
                            }
                            msg
                            creator
                in
                case maybeMsg of
                    Nothing ->
                        ( PrepareSecond opponent state creator_
                        , Cmd.map CreatorMsg cmd
                        , Nothing
                        )

                    Just msg2 ->
                        update { onLeave = onLeave }
                            msg2
                            (PrepareSecond opponent state creator_)

        ( PrepareSecond opponent _ _, LevelReady state ) ->
            let
                withControls bottle_ =
                    case opponent of
                        Human ->
                            Bottle.withControls Controls.arrows bottle_

                        Bot ->
                            Bottle.withBot Bot.trashBot bottle_

                state_ =
                    mapPlayer Second (mapBottle withControls) state
            in
            Playing state_ |> withNothing

        ( PrepareSecond _ _ _, _ ) ->
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
                    (mapBottle (Bottle.withBombs colors))
                    state
            , Cmd.none
            , Nothing
            )

        ( Playing state, BottleMsg msg ) ->
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


getWinner : State -> Maybe Position
getWinner { first, second } =
    if Bottle.totalViruses first.bottle.contents == 0 || Bottle.hasConflict second.bottle then
        Just First

    else if Bottle.totalViruses second.bottle.contents == 0 || Bottle.hasConflict first.bottle then
        Just Second

    else
        Nothing


updatePlayState : msg -> BottleMsg -> State -> ( Model, Cmd Msg, Maybe msg )
updatePlayState onLeave action ({ first, second } as model) =
    case action of
        FirstBottleMsg msg ->
            Bottle.update { onBomb = Bomb Second >> Just } msg first.bottle
                |> Component.raiseOutMsg (update { onLeave = onLeave })
                    (\bottle ->
                        Playing
                            { model | first = mapBottle (\_ -> bottle) first }
                    )
                    (FirstBottleMsg >> BottleMsg)

        SecondBottleMsg msg ->
            Bottle.update { onBomb = Bomb First >> Just } msg second.bottle
                |> Component.raiseOutMsg (update { onLeave = onLeave })
                    (\bottle ->
                        Playing
                            { model | second = mapBottle (\_ -> bottle) second }
                    )
                    (SecondBottleMsg >> BottleMsg)



-- VIEW --


view : Model -> Html Msg
view model =
    case model of
        PrepareFirst _ _ _ ->
            div [] [ text "💊💊💊" ]

        PrepareSecond _ _ _ ->
            div [] [ text "💊💊💊" ]

        Playing { first, second } ->
            div []
                [ div
                    [ style "display" "flex"
                    , style "flex-direction" "row"
                    ]
                    [ viewPlayer first
                    , div [ style "margin" "0 12px" ]
                        -- TODO: displays win count
                        [ h3 [] [ text "level" ]
                        , spaceBetween []
                            [ span [] [ (String.fromInt >> text) first.level ]
                            , span [] [ (String.fromInt >> text) second.level ]
                            ]
                        , h3 [] [ text "speed" ]
                        , spaceBetween []
                            [ span [] [ (Bottle.speedToString >> text) first.speed ]
                            , span [] [ (Bottle.speedToString >> text) second.speed ]
                            ]
                        , h3 [] [ text "virus" ]
                        , spaceBetween []
                            [ span [] [ text <| displayViruses first ]
                            , span [] [ text <| displayViruses second ]
                            ]
                        ]
                    , viewPlayer second
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
