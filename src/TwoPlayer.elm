module TwoPlayer exposing
    ( Model(..)
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Component
import Html exposing (Html)
import OnePlayer.Menu as Menu
import Speed exposing (Speed(..))
import TwoPlayer.Game as Game


init : Game.GameType -> ( Model, Cmd Msg )
init type_ =
    ( Init type_ Menu.init, Cmd.none )


type Model
    = Init Game.GameType Menu.Model
    | InGame Game.GameType Menu.Model Game.Model


type Msg
    = Start { level : Int, speed : Speed }
    | MenuMsg Menu.Msg
    | GameMsg Game.Msg
    | Reset


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case ( model, action ) of
        ( Init opponent menu, Start { level, speed } ) ->
            Game.init
                opponent
                { level = level, speed = speed }
                { level = level, speed = speed }
                |> Tuple.mapFirst (InGame opponent menu)
                |> Tuple.mapSecond (Cmd.map GameMsg)

        ( Init opponent state, MenuMsg msg ) ->
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
                |> Component.mapOutMsg update (Init opponent) MenuMsg

        ( InGame opponent menu state, GameMsg msg ) ->
            state
                |> Game.update { onLeave = Reset } msg
                |> Component.mapOutMsg update (InGame opponent menu) GameMsg

        ( InGame opponent menu _, Reset ) ->
            ( Init opponent menu, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Init _ state ->
            Sub.map MenuMsg <| Menu.subscriptions state

        InGame _ _ state ->
            Sub.map GameMsg <| Game.subscriptions state


view : Model -> Html Msg
view model =
    case model of
        Init _ state ->
            Menu.view state

        InGame _ _ state ->
            Game.view state
                |> Html.map GameMsg
