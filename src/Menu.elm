module Menu exposing (..)

import Html exposing (Html, h3, div, text)
import Html.Attributes exposing (style, type_)
import Html.Events exposing (onClick)
import Keyboard exposing (KeyCode)
import Game exposing (Speed(..))


type Msg
    = KeyChange Bool KeyCode


type Selection
    = Speed
    | Level


type alias State =
    { level : Int, speed : Speed, selecting : Selection }


init : State
init =
    { level = 10, speed = Med, selecting = Level }


subscriptions : State -> Sub Msg
subscriptions { speed } =
    Sub.batch
        [ Keyboard.downs (KeyChange True)
        , Keyboard.ups (KeyChange False)
        ]


update : Msg -> State -> State
update msg ({ selecting, speed } as state) =
    case msg of
        KeyChange True code ->
            let
                other : Selection
                other =
                    case selecting of
                        Speed ->
                            Level

                        Level ->
                            Speed
            in
                case code of
                    -- up
                    38 ->
                        { state | selecting = other }

                    -- left
                    37 ->
                        case ( selecting, speed ) of
                            ( Level, _ ) ->
                                { state | level = max 0 (state.level - 1) }

                            ( Speed, High ) ->
                                { state | speed = Med }

                            ( Speed, Med ) ->
                                { state | speed = Low }

                            ( Speed, _ ) ->
                                state

                    -- right
                    39 ->
                        case ( selecting, speed ) of
                            ( Level, _ ) ->
                                { state | level = min 20 (state.level + 1) }

                            ( Speed, Low ) ->
                                { state | speed = Med }

                            ( Speed, Med ) ->
                                { state | speed = High }

                            ( Speed, _ ) ->
                                state

                    -- down
                    40 ->
                        { state | selecting = other }

                    _ ->
                        state

        KeyChange False code ->
            state


view : State -> List (Html Msg)
view { level, speed, selecting } =
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
