module Main exposing (..)

import Html exposing (Html, h1, text, div, button)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Component
import OnePlayer
import TwoPlayer


main : Program Never Model Msg
main =
    Html.program
        { init = ( Selecting, Cmd.none )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Model
    = Selecting
    | One OnePlayer.Model
    | Two TwoPlayer.Model


type Msg
    = OneMsg OnePlayer.Msg
    | TwoMsg TwoPlayer.Msg
    | PlayOne
    | PlayTwo


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        One state ->
            OnePlayer.subscriptions state
                |> Sub.map OneMsg

        Two state ->
            TwoPlayer.subscriptions state
                |> Sub.map TwoMsg

        _ ->
            Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( Selecting, PlayOne ) ->
            OnePlayer.init
                |> Tuple.mapFirst One
                |> Tuple.mapSecond (Cmd.map OneMsg)

        ( Selecting, PlayTwo ) ->
            TwoPlayer.init
                |> Tuple.mapFirst Two
                |> Tuple.mapSecond (Cmd.map TwoMsg)

        ( One state, OneMsg msg ) ->
            OnePlayer.update msg state
                |> Component.mapSimple update One OneMsg

        ( Two state, TwoMsg msg ) ->
            TwoPlayer.update msg state
                |> Component.mapSimple update Two TwoMsg

        ( _, _ ) ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-direction", "column" )
            , ( "align-items", "center" )
            ]
        ]
        [ h1 [] [ text "dr. mario 💊" ]
        , case model of
            Selecting ->
                viewSelecting

            One state ->
                OnePlayer.view state
                    |> Html.map OneMsg

            Two state ->
                TwoPlayer.view state
                    |> Html.map TwoMsg
        ]


viewSelecting : Html Msg
viewSelecting =
    div []
        [ button [ onClick PlayOne ] [ text "1p" ]
        , button [ onClick PlayTwo ] [ text "2p" ]
        ]
