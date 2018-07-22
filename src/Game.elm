module Game exposing (..)

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


type Speed
    = Low
    | Med
    | High


type alias State =
    { bottle : Bottle.Model
    , level : Int
    , score : Int
    , speed : Speed
    }


type Model
    = PrepareGame
        { level : Int
        , score : Int
        , bottle : Bottle.Model
        , speed : Speed
        }
    | Playing State
    | Paused State
    | Over
        { won : Bool
        , game : State
        }


type Msg
    = TickTock Time
    | BottleMsg Bottle.Msg
    | Advance
        { level : Int
        , score : Int
        , speed : Speed
        }
    | NewVirus ( Color, Grid.Coords )
    | InitPill ( Color, Color )
    | Pause
    | Resume
    | Reset


type Key
    = Up
    | Down
    | Left
    | Right
    | Noop


init : Int -> Speed -> ( Model, Cmd Msg )
init level speed =
    initWithScore level speed 0


initWithScore level speed score =
    let
        bottle =
            Bottle.init
    in
        ( PrepareGame
            { level = level
            , score = score
            , bottle = bottle
            , speed = speed
            }
        , randomNewVirus bottle.contents
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Playing { speed, bottle } ->
            Sub.batch
                [ Time.every (tickForSpeed speed) TickTock
                , Bottle.subscriptions bottle
                    |> Sub.map BottleMsg
                ]

        _ ->
            Sub.none



-- SETTINGS --


virusesForLevel : Int -> Int
virusesForLevel level =
    min 84 (4 * level + 4)


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


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case ( model, action ) of
        ( PrepareGame ({ level, score, bottle } as state), NewVirus ( color, coords ) ) ->
            let
                newBottle =
                    Bottle.withVirus color coords bottle
            in
                if Bottle.isCleared coords newBottle.contents then
                    -- would create a 4-in-a-row, so let's try a new virus
                    ( PrepareGame state, randomNewVirus bottle.contents )
                else if Bottle.totalViruses newBottle.contents >= virusesForLevel level then
                    ( PrepareGame { state | bottle = newBottle }
                    , Random.generate InitPill <|
                        Bottle.generatePill
                    )
                else
                    ( PrepareGame { state | bottle = newBottle }
                    , randomNewVirus newBottle.contents
                    )

        ( PrepareGame { level, bottle, score, speed }, InitPill colors ) ->
            ( Playing
                { level = level
                , bottle =
                    bottle |> Bottle.withNext colors
                , score = score
                , speed = speed
                }
            , Cmd.none
            )

        ( PrepareGame _, _ ) ->
            ( model, Cmd.none )

        ( Playing state, Pause ) ->
            ( Paused state, Cmd.none )

        ( Paused state, Resume ) ->
            ( Playing state, Cmd.none )

        ( Paused state, _ ) ->
            ( model, Cmd.none )

        ( Playing state, msg ) ->
            if Bottle.totalViruses state.bottle.contents == 0 then
                ( Over
                    { won = True
                    , game = state
                    }
                , Cmd.none
                )
            else if isOver state then
                ( Over
                    { won = False
                    , game = state
                    }
                , Cmd.none
                )
            else
                updatePlayState msg state

        ( Over _, Advance { level, score, speed } ) ->
            initWithScore level speed score

        ( Over _, _ ) ->
            ( model, Cmd.none )


updatePlayState : Msg -> State -> ( Model, Cmd Msg )
updatePlayState action ({ bottle, speed, score } as model) =
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
            TickTock _ ->
                Bottle.advance model.bottle
                    |> Tuple.mapFirst withBottle
                    |> Tuple.mapSecond (Cmd.map BottleMsg)

            BottleMsg msg ->
                Bottle.update msg model.bottle
                    |> Component.mapOutMsg update
                        withBottle
                        BottleMsg

            _ ->
                -- TODO: get rid of this
                ( Playing model, Cmd.none )


sweep : State -> State
sweep ({ bottle, score, speed } as model) =
    let
        newBottle =
            Bottle.sweep bottle

        sweptViruses =
            (Bottle.totalViruses bottle.contents) - (Bottle.totalViruses newBottle.contents)

        additionalPoints =
            pointsForClearedViruses speed sweptViruses
    in
        { model | bottle = newBottle, score = score + additionalPoints }



-- QUERIES


isOver : State -> Bool
isOver state =
    Bottle.hasConflict state.bottle



-- GENERATORS


randomNewVirus : Bottle -> Cmd Msg
randomNewVirus bottle =
    Random.generate NewVirus <|
        Random.pair Bottle.generateColor (Bottle.generateEmptyCoords bottle)



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
                [ (Tuple.first >> Bottle.viewPill) bottle.next
                , (Tuple.second >> Bottle.viewPill) bottle.next
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
