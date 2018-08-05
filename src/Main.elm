module Main exposing (..)

import Html exposing (Html, h1, text, div, button)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Component
import OnePlayer


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
    | Two


type Msg
    = OneMsg OnePlayer.Msg
    | TwoMsg
    | PlayOne
    | PlayTwo


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        One state ->
            OnePlayer.subscriptions state
                |> Sub.map OneMsg

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
            ( Two, Cmd.none )

        ( One state, OneMsg msg ) ->
            OnePlayer.update msg state
                |> Component.mapSimple update One OneMsg

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

            Two ->
                --TwoPlayer.view model
                text "TODO: build it"
        ]


viewSelecting : Html Msg
viewSelecting =
    div []
        [ button [ onClick PlayOne ] [ text "1p" ]
        , button [ onClick PlayTwo ] [ text "2p" ]
        ]
