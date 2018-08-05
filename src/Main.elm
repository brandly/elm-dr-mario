module Main exposing (..)

import Html exposing (Html, h1, text, div)
import Html.Attributes exposing (style)
import OnePlayer


main : Program Never OnePlayer.Model OnePlayer.Msg
main =
    Html.program
        { init = OnePlayer.init
        , update = OnePlayer.update
        , view = view
        , subscriptions = OnePlayer.subscriptions
        }


view : OnePlayer.Model -> Html OnePlayer.Msg
view model =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-direction", "column" )
            , ( "align-items", "center" )
            ]
        ]
        [ h1 [] [ text "dr. mario 💊" ]
        , OnePlayer.view model
        ]
