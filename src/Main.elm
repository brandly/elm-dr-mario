module Main exposing (..)

import Html exposing (Html, h1, text, div, p)
import Html.Attributes exposing (style)
import Time exposing (Time, second)
import OnePlayer.Menu as Menu
import OnePlayer.Game as Game
import Component


main : Program Never Model Msg
main =
    Html.program
        { init = ( Init Menu.init, Cmd.none )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Model
    = Init Menu.State
    | InGame Game.Model


type Msg
    = MenuMsg Menu.Msg
    | Start { level : Int, speed : Game.Speed }
    | GameMsg Game.Msg
    | Reset


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case ( model, action ) of
        ( _, Start { level, speed } ) ->
            Game.init level speed
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
    div [ style [ ( "display", "flex" ), ( "flex-direction", "column" ), ( "align-items", "center" ) ] ]
        [ h1 [] [ text "dr. mario 💊" ]
        , case model of
            Init state ->
                Menu.view state

            InGame state ->
                Game.view state
                    |> Html.map GameMsg
        ]
