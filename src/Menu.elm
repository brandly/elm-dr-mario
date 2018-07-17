module Menu exposing (..)

import Html exposing (Html, h3, div, text, input)
import Html.Attributes exposing (style, type_)
import Html.Events exposing (onSubmit)
import Keyboard exposing (KeyCode)
import Game exposing (Speed(..))


type Msg
    = Up
    | Left
    | Right
    | Down
    | Noop


type Selection
    = Speed
    | Level


type alias State =
    { level : Int, speed : Speed, selecting : Selection }


init : State
init =
    { level = 10, speed = Med, selecting = Level }


subscriptions : State -> Sub Msg
subscriptions _ =
    Keyboard.downs
        (\keyCode ->
            case keyCode of
                38 ->
                    Up

                37 ->
                    Left

                39 ->
                    Right

                40 ->
                    Down

                _ ->
                    Noop
        )


update : Msg -> State -> State
update msg ({ selecting, speed } as state) =
    let
        other : Selection
        other =
            case selecting of
                Speed ->
                    Level

                Level ->
                    Speed
    in
        case msg of
            Up ->
                { state | selecting = other }

            Down ->
                { state | selecting = other }

            Left ->
                case ( selecting, speed ) of
                    ( Level, _ ) ->
                        { state | level = max 0 (state.level - 1) }

                    ( Speed, High ) ->
                        { state | speed = Med }

                    ( Speed, Med ) ->
                        { state | speed = Low }

                    ( Speed, _ ) ->
                        state

            Right ->
                case ( selecting, speed ) of
                    ( Level, _ ) ->
                        { state | level = min 20 (state.level + 1) }

                    ( Speed, Low ) ->
                        { state | speed = Med }

                    ( Speed, Med ) ->
                        { state | speed = High }

                    ( Speed, _ ) ->
                        state

            Noop ->
                state


view : { onSubmit : State -> msg } -> State -> Html msg
view events ({ level, speed, selecting } as state) =
    Html.form
        [ onSubmit (events.onSubmit state) ]
        [ heading (selecting == Level) "virus level"
        , div []
            ((List.range 0 20)
                |> List.map (toButton level)
            )
        , heading (selecting == Speed) "speed"
        , div []
            ([ Low, Med, High ]
                |> List.map (toButton speed)
            )
        , input [ style [ ( "margin", "16px 0" ) ], type_ "submit" ] []
        ]


heading : Bool -> String -> Html msg
heading selected str =
    h3 []
        [ text
            (if selected then
                "💊" ++ str
             else
                str
            )
        ]


toButton : a -> a -> Html msg
toButton ideal real =
    Html.button
        [ type_ "button"
        , style
            (if real == ideal then
                [ ( "border", "3px solid blue" ) ]
             else
                []
            )
        ]
        [ (toString >> text) real ]
