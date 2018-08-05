module TwoPlayer exposing (..)

import Html exposing (Html, text)
import Time exposing (Time, second)


--import TwoPlayer.Menu as Menu

import Bottle exposing (Speed(..))
import TwoPlayer.Game as Game
import Component


init : ( Model, Cmd Msg )
init =
    --( Init Menu.init, Cmd.none )
    (Game.init
        { level = 10, speed = Med }
        { level = 10, speed = Med }
    )
        |> Tuple.mapFirst InGame
        |> Tuple.mapSecond (Cmd.map GameMsg)


type Model
    = Init --Menu.State
    | InGame Game.Model


type Msg
    = Start --{ level : Int, speed : Game.Speed }
      --| MenuMsg Menu.Msg
    | GameMsg Game.Msg
    | Reset


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case ( model, action ) of
        --( _, Start { level, speed } ) ->
        --    Game.init level speed
        --        |> Tuple.mapFirst InGame
        --        |> Tuple.mapSecond (Cmd.map GameMsg)
        --( Init state, MenuMsg msg ) ->
        --    state
        --        |> Menu.update
        --            { onSubmit =
        --                \{ level, speed } ->
        --                    Start
        --                        { level = level
        --                        , speed = speed
        --                        }
        --            }
        --            msg
        --        |> Component.mapOutMsg update Init MenuMsg
        ( InGame state, GameMsg msg ) ->
            state
                |> Game.update { onLeave = Reset } msg
                |> Component.mapOutMsg update InGame GameMsg

        --( InGame state, Reset ) ->
        --    ( Init Menu.init, Cmd.none )
        ( _, _ ) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Init ->
            --Sub.map MenuMsg <| Menu.subscriptions state
            Sub.none

        InGame state ->
            Sub.map GameMsg <| Game.subscriptions state


view : Model -> Html Msg
view model =
    case model of
        Init ->
            --Menu.view state
            text "TODO: build it"

        InGame state ->
            Game.view state
                |> Html.map GameMsg
