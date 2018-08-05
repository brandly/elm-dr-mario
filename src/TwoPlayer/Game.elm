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
        --( PrepareGame ({ score, creator, speed } as state), CreatorMsg msg ) ->
        --    let
        --        ( creator_, cmd, maybeMsg ) =
        --            LevelCreator.update
        --                { onCreated =
        --                    (\{ level, bottle } ->
        --                        LevelReady
        --                            { bottle = bottle
        --                            , level = level
        --                            , score = score
        --                            , speed = speed
        --                            }
        --                    )
        --                }
        --                msg
        --                creator
        --    in
        --        case maybeMsg of
        --            Nothing ->
        --                ( PrepareGame { state | creator = creator_ }
        --                , Cmd.map CreatorMsg cmd
        --                , Nothing
        --                )
        --            Just msg2 ->
        --                update { onLeave = onLeave }
        --                    msg2
        --                    (PrepareGame { state | creator = creator_ })
        --( PrepareGame _, LevelReady state ) ->
        --    ( Playing
        --        { state | bottle = Bottle.withControls controls state.bottle }
        --    , Cmd.none
        --    , Nothing
        --    )
        --( PrepareGame _, _ ) ->
        --    ( model, Cmd.none, Nothing )
        --( Playing state, Pause ) ->
        --    ( Paused state, Cmd.none, Nothing )
        --( Paused state, Resume ) ->
        --    ( Playing state, Cmd.none, Nothing )
        --( Paused state, _ ) ->
        --    ( model, Cmd.none, Nothing )
        --( Playing state, msg ) ->
        --    if Bottle.totalViruses state.bottle.contents == 0 then
        --        ( Over
        --            { won = True
        --            , game = state
        --            }
        --        , Cmd.none
        --        , Nothing
        --        )
        --    else if Bottle.hasConflict state.bottle then
        --        ( Over
        --            { won = False
        --            , game = state
        --            }
        --        , Cmd.none
        --        , Nothing
        --        )
        --    else
        --        updatePlayState onLeave msg state
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



--updatePlayState : msg -> Msg -> State -> ( Model, Cmd Msg, Maybe msg )
--updatePlayState onLeave action ({ bottle, speed, score } as model) =
--    let
--        withBottle : Bottle.Model -> Model
--        withBottle newBottle =
--            let
--                sweptViruses =
--                    (Bottle.totalViruses bottle.contents) - (Bottle.totalViruses newBottle.contents)
--                additionalPoints =
--                    pointsForClearedViruses speed sweptViruses
--            in
--                Playing
--                    { model
--                        | bottle = newBottle
--                        , score = score + additionalPoints
--                    }
--    in
--        case action of
--            TickTock _ ->
--                let
--                    ( a, b ) =
--                        Bottle.advance model.bottle
--                            |> Tuple.mapFirst withBottle
--                            |> Tuple.mapSecond (Cmd.map BottleMsg)
--                in
--                    ( a, b, Nothing )
--            BottleMsg msg ->
--                Bottle.update msg model.bottle
--                    |> Component.raiseOutMsg (update { onLeave = onLeave })
--                        withBottle
--                        BottleMsg
--            _ ->
--                -- TODO: get rid of this
--                ( Playing model, Cmd.none, Nothing )
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



-- UTILS --


applyNtimes : Int -> (a -> a) -> a -> a
applyNtimes n f x =
    if n <= 0 then
        x
    else if n == 1 then
        f x
    else
        f (applyNtimes (n - 1) f x)
