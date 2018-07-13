module Menu exposing (..)

import Html exposing (Html, h3, div, text)
import Html.Attributes exposing (style, type_)
import Html.Events exposing (onClick)
import Game exposing (Speed(..))


type Msg
    = SetLevel Int
    | SetSpeed Speed


type alias State =
    { level : Int, speed : Speed }


init : State
init =
    { level = 10, speed = Med }


update : Msg -> State -> State
update msg state =
    case msg of
        SetLevel level ->
            { state | level = level }

        SetSpeed speed ->
            { state | speed = speed }


view : State -> List (Html Msg)
view state =
    [ h3 [] [ text "virus level" ]
    , div []
        ((List.range 0 20)
            |> List.map (toButton SetLevel state.level)
        )
    , h3 [] [ text "speed" ]
    , div []
        ([ Low, Med, High ]
            |> List.map (toButton SetSpeed state.speed)
        )
    ]


toButton : (a -> msg) -> a -> a -> Html msg
toButton toMsg ideal real =
    Html.button
        [ type_ "button"
        , onClick (toMsg real)
        , style
            (if real == ideal then
                [ ( "border", "3px solid blue" ) ]
             else
                []
            )
        ]
        [ (toString >> text) real ]
