module TwoPlayer exposing (Model(..), Msg(..), init, subscriptions, update, view)

import Bottle exposing (Speed(..))
import Component
import Controls
import Html exposing (Html, text)
import OnePlayer.Menu as Menu
import TwoPlayer.Game as Game


init : ( Model, Cmd Msg )
init =
    ( Init Menu.init, Cmd.none )


type Model
    = Init Menu.State
    | InGame Game.Model


type Msg
    = Start { level : Int, speed : Speed }
    | MenuMsg Menu.Msg
    | GameMsg Game.Msg
    | Reset


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case ( model, action ) of
        ( Init _, Start { level, speed } ) ->
            Game.init
                { level = level, speed = speed }
                { level = level, speed = speed }
                |> Tuple.mapFirst InGame
                |> Tuple.mapSecond (Cmd.map GameMsg)

        ( Init state, MenuMsg msg ) ->
            state
                |> Menu.update
                    { onSubmit =
                        \{ level, speed } ->
                            Start
                                { level = level
                                , speed = speed
                                }
                    }
                    msg
                |> Component.mapOutMsg update Init MenuMsg

        ( InGame state, GameMsg msg ) ->
            state
                |> Game.update { onLeave = Reset } msg
                |> Component.mapOutMsg update InGame GameMsg

        ( InGame state, Reset ) ->
            ( Init Menu.init, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Init state ->
            Sub.map MenuMsg <| Menu.subscriptions state

        InGame state ->
            Sub.map GameMsg <| Game.subscriptions state


view : Model -> Html Msg
view model =
    case model of
        Init state ->
            Menu.view state

        InGame state ->
            Game.view state
                |> Html.map GameMsg