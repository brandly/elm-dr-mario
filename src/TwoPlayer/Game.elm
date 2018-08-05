module TwoPlayer.Game exposing (..)

import Grid exposing (Cell, Column, Grid)
import Html exposing (Html, h1, h3, text, div, p)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Keyboard exposing (KeyCode)
import Random exposing (Generator(..))
import RandomExtra exposing (selectWithDefault)
import Time exposing (Time)
import Element exposing (Element, px, styled, none)
import Bottle exposing (Bottle, Color(..))
import Component
import LevelCreator


type Speed
    = Low
    | Med
    | High


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
    = TickTock Time
    | FirstBottleMsg Bottle.Msg
    | SecondBottleMsg Bottle.Msg
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


type alias Options =
    { level : Int, speed : Speed }


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


controls : Int -> Maybe Bottle.Direction
controls keyCode =
    case keyCode of
        38 ->
            Just Bottle.Up

        37 ->
            Just Bottle.Left

        39 ->
            Just Bottle.Right

        40 ->
            Just Bottle.Down

        _ ->
            Nothing


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Playing { first, second } ->
            Sub.batch
                [ Time.every (tickForSpeed first.speed) TickTock
                , Time.every (tickForSpeed second.speed) TickTock
                , Bottle.subscriptions first.bottle
                    |> Sub.map FirstBottleMsg
                , Bottle.subscriptions second.bottle
                    |> Sub.map SecondBottleMsg
                ]

        _ ->
            Sub.none



-- SETTINGS --


tickForSpeed : Speed -> Time
tickForSpeed speed =
    case speed of
        High ->
            300 * Time.millisecond

        Med ->
            700 * Time.millisecond

        Low ->
            Time.second



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
                                    { state | first = { first | bottle = bottle } }
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
                                    { state | second = { second | bottle = bottle } }
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

        --( PrepareGame _, _ ) ->
        --    ( model, Cmd.none, Nothing )
        --( Playing state, Pause ) ->
        --    ( Paused state, Cmd.none, Nothing )
        --( Paused state, Resume ) ->
        --    ( Playing state, Cmd.none, Nothing )
        --( Paused state, _ ) ->
        --    ( model, Cmd.none, Nothing )
        ( Playing state, msg ) ->
            --if Bottle.totalViruses state.bottle.contents == 0 then
            --    ( Over
            --        { won = True
            --        , game = state
            --        }
            --    , Cmd.none
            --    , Nothing
            --    )
            --else if Bottle.hasConflict state.bottle then
            --    ( Over
            --        { won = False
            --        , game = state
            --        }
            --    , Cmd.none
            --    , Nothing
            --    )
            --else
            updatePlayState onLeave msg state

        --( Over _, Advance { level, score, speed } ) ->
        --    let
        --        ( model, msg ) =
        --            initWithScore level speed score
        --    in
        --        ( model, msg, Nothing )
        --( Over _, Reset ) ->
        --    ( model, Cmd.none, Just onLeave )
        --( Over _, _ ) ->
        ( _, _ ) ->
            ( model, Cmd.none, Nothing )


updatePlayState : msg -> Msg -> State -> ( Model, Cmd Msg, Maybe msg )
updatePlayState onLeave action ({ first, second } as model) =
    let
        withBottle : Bottle.Model -> Player -> Player
        withBottle newBottle player =
            { player | bottle = newBottle }
    in
        case action of
            -- TODO: bottles should advance themselves, own Speed,
            --TickTock _ ->
            --    let
            --        ( a, b ) =
            --            Bottle.advance model.bottle
            --                |> Tuple.mapFirst withBottle
            --                |> Tuple.mapSecond (Cmd.map BottleMsg)
            --    in
            --        ( a, b, Nothing )
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
            div [] []


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
