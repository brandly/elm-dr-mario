module TwoPlayer.Game exposing (..)

import Html exposing (Html, h1, h3, text, div, p)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Element exposing (Element, px, styled, none)
import Bottle exposing (Bottle, Color(..), Speed(..))
import Component
import LevelCreator
import Controls


type alias Player =
    { bottle : Bottle.Model
    , level : Int
    , speed : Speed
    }


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
                            (\{ level, bottle } ->
                                LevelReady
                                    { state | first = { first | bottle = Bottle.withControls Controls.wasd bottle } }
                            )
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

        ( PrepareFirst _ creator, LevelReady state ) ->
            let
                ( creator, cmd ) =
                    LevelCreator.init state.second.level
            in
                ( PrepareSecond state creator
                , Cmd.map CreatorMsg cmd
                , Nothing
                )

        ( PrepareFirst _ _, _ ) ->
            ( model, Cmd.none, Nothing )

        ( PrepareSecond state creator, CreatorMsg msg ) ->
            let
                -- TODO: if you choose same levels, should have same bottles
                second =
                    state.second

                ( creator_, cmd, maybeMsg ) =
                    LevelCreator.update
                        { onCreated =
                            (\{ level, bottle } ->
                                LevelReady
                                    { state | second = { second | bottle = Bottle.withControls Controls.arrows bottle } }
                            )
                        }
                        msg
                        creator
            in
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

        ( PrepareSecond _ creator, LevelReady state ) ->
            ( Playing state, Cmd.none, Nothing )

        ( PrepareSecond _ _, _ ) ->
            ( model, Cmd.none, Nothing )

        ( Playing state, Pause ) ->
            ( Paused state, Cmd.none, Nothing )

        ( Paused state, Resume ) ->
            ( Playing state, Cmd.none, Nothing )

        ( Paused state, _ ) ->
            ( model, Cmd.none, Nothing )

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
    let
        withBottle : Bottle.Model -> Player -> Player
        withBottle newBottle player =
            { player | bottle = newBottle }
    in
        case action of
            FirstBottleMsg msg ->
                Bottle.update msg first.bottle
                    |> Component.raiseOutMsg (update { onLeave = onLeave })
                        (\bottle ->
                            Playing
                                { model | first = withBottle bottle first }
                        )
                        FirstBottleMsg

            SecondBottleMsg msg ->
                Bottle.update msg second.bottle
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
            div
                [ style
                    [ ( "display", "flex" )
                    , ( "flex-direction", "row" )
                    ]
                ]
                [ viewPlayer state.first
                , viewPlayer state.second
                ]

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


viewPlayer : Player -> Html msg
viewPlayer { bottle, level, speed } =
    div [ style [ ( "display", "flex" ) ] ]
        [ Bottle.view bottle
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
