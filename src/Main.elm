module Main exposing (Model(..), Msg(..), main, subscriptions, update, view)

import Browser
import Component
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (style)
import Menu
import OnePlayer
import Tutorial
import TwoPlayer
import TwoPlayer.Game


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( Selecting Menu.init, Cmd.none )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Model
    = Selecting Menu.Model
    | Tutorial Tutorial.Model
    | One OnePlayer.Model
    | Two TwoPlayer.Model


type Msg
    = MenuMsg Menu.Msg
    | OneMsg OnePlayer.Msg
    | TwoMsg TwoPlayer.Msg
    | TutorialMsg Tutorial.Msg
    | PlayOne
    | PlayTwo
    | PlayBot
    | ViewTutorial
    | FinishTutorial


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        One state ->
            OnePlayer.subscriptions state
                |> Sub.map OneMsg

        Two state ->
            TwoPlayer.subscriptions state
                |> Sub.map TwoMsg

        Selecting state ->
            Menu.subscriptions state
                |> Sub.map MenuMsg

        Tutorial state ->
            Tutorial.subscriptions state
                |> Sub.map TutorialMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( Selecting state, MenuMsg msg_ ) ->
            Menu.update
                { onSubmit =
                    \selection ->
                        case selection of
                            Menu.OnePlayer ->
                                PlayOne

                            Menu.TwoPlayer ->
                                PlayTwo

                            Menu.VsBot ->
                                PlayBot

                            Menu.Tutorial ->
                                ViewTutorial
                }
                msg_
                state
                |> Component.mapOutMsg update Selecting MenuMsg

        ( Selecting _, PlayOne ) ->
            OnePlayer.init
                |> Tuple.mapFirst One
                |> Tuple.mapSecond (Cmd.map OneMsg)

        ( Selecting _, PlayTwo ) ->
            TwoPlayer.init TwoPlayer.Game.VsHuman
                |> Tuple.mapFirst Two
                |> Tuple.mapSecond (Cmd.map TwoMsg)

        ( Selecting _, PlayBot ) ->
            TwoPlayer.init TwoPlayer.Game.VsBot
                |> Tuple.mapFirst Two
                |> Tuple.mapSecond (Cmd.map TwoMsg)

        ( Selecting _, ViewTutorial ) ->
            Tutorial.init
                |> Tuple.mapFirst Tutorial
                |> Tuple.mapSecond (Cmd.map TutorialMsg)

        ( One state, OneMsg msg_ ) ->
            OnePlayer.update msg_ state
                |> Component.mapSimple One OneMsg

        ( Two state, TwoMsg msg_ ) ->
            TwoPlayer.update msg_ state
                |> Component.mapSimple Two TwoMsg

        ( Tutorial state, TutorialMsg msg_ ) ->
            Tutorial.update { onCompletion = FinishTutorial } msg_ state
                |> Component.mapOutMsg update Tutorial TutorialMsg

        ( Tutorial state, FinishTutorial ) ->
            ( Selecting Menu.init, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "align-items" "center"
        ]
        [ h1 [] [ text "Dr. MARIO 💊" ]
        , case model of
            Selecting state ->
                Menu.view state |> Html.map MenuMsg

            One state ->
                OnePlayer.view state
                    |> Html.map OneMsg

            Two state ->
                TwoPlayer.view state
                    |> Html.map TwoMsg

            Tutorial state ->
                Tutorial.view state
                    |> Html.map TutorialMsg
        ]
