module OnePlayer.Menu exposing
    ( Msg(..)
    , State
    , init
    , subscriptions
    , update
    , view
    )

import Bottle exposing (Speed(..))
import Browser.Events exposing (onKeyDown)
import Element exposing (Element, px, styled)
import Html exposing (Html, div, h3, h4, p, text)
import Html.Attributes exposing (style)
import Html.Events exposing (keyCode)
import Json.Decode as Decode


type Msg
    = Up
    | Left
    | Right
    | Down
    | Enter
    | Noop


type Selection
    = Speed
    | Level


type alias State =
    { level : Int
    , speed : Speed
    , selecting : Selection
    }


init : State
init =
    { level = 10, speed = Med, selecting = Level }


subscriptions : State -> Sub Msg
subscriptions _ =
    onKeyDown
        (Decode.map
            (\key ->
                case key of
                    13 ->
                        Enter

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
            keyCode
        )


update :
    { onSubmit : { level : Int, speed : Speed } -> msg }
    -> Msg
    -> State
    -> ( State, Cmd Msg, Maybe msg )
update events msg ({ selecting, speed } as state) =
    let
        other : Selection
        other =
            case selecting of
                Speed ->
                    Level

                Level ->
                    Speed

        withNothing s =
            ( s, Cmd.none, Nothing )
    in
    case msg of
        Up ->
            withNothing { state | selecting = other }

        Down ->
            withNothing { state | selecting = other }

        Left ->
            withNothing
                (case ( selecting, speed ) of
                    ( Level, _ ) ->
                        { state | level = max 0 (state.level - 1) }

                    ( Speed, High ) ->
                        { state | speed = Med }

                    ( Speed, Med ) ->
                        { state | speed = Low }

                    ( Speed, _ ) ->
                        state
                )

        Right ->
            withNothing
                (case ( selecting, speed ) of
                    ( Level, _ ) ->
                        { state | level = min 20 (state.level + 1) }

                    ( Speed, Low ) ->
                        { state | speed = Med }

                    ( Speed, Med ) ->
                        { state | speed = High }

                    ( Speed, _ ) ->
                        state
                )

        Enter ->
            ( state
            , Cmd.none
            , Just <| events.onSubmit { level = state.level, speed = state.speed }
            )

        Noop ->
            withNothing state


view : State -> Html msg
view { level, speed, selecting } =
    div
        [ style "width" "420px", style "max-width" "100%" ]
        [ row []
            [ heading (selecting == Level) "virus level"
            , viewLevel level
            ]
        , row []
            [ heading (selecting == Speed) "speed"
            , div
                [ style "width" "100%"
                , style "display" "flex"
                , style "justify-content" "space-around"
                ]
                ([ Low, Med, High ]
                    |> List.map (viewSpeed speed)
                )
            ]
        , btw [] [ text "use arrows, hit enter" ]
        ]


viewLevel : Int -> Html msg
viewLevel level =
    div [ style "padding" "0 24px" ]
        [ h4 [ style "text-align" "right" ] [ (String.fromInt >> text) level ]
        , viewLevelSlider level
        ]


viewLevelSlider : Int -> Html msg
viewLevelSlider level =
    div
        [ style "display" "flex"
        , style "justify-content" "space-between"
        , style "align-items" "center"
        ]
        (List.range 0 20
            |> List.map
                (\n ->
                    div
                        [ style "height"
                            (px
                                (if modBy 5 n == 0 then
                                    16

                                 else
                                    8
                                )
                            )
                        , style "width" "4px"
                        , style "background"
                            (if n == level then
                                "#fb7c54"

                             else
                                "#000"
                            )
                        ]
                        []
                )
        )


btw : Element msg
btw =
    styled p
        [ ( "font-color", "#666" )
        , ( "text-align", "center" )
        ]


heading : Bool -> String -> Html msg
heading selected str =
    h3
        []
        [ text <|
            if selected then
                ">" ++ str ++ "<"

            else
                str
        ]


row : Element msg
row =
    styled div [ ( "margin-bottom", "48px" ) ]


viewSpeed : Speed -> Speed -> Html msg
viewSpeed ideal real =
    h4
        [ style "padding" "4px 8px"
        , if real == ideal then
            style "border" "3px solid #fb7c54"

          else
            style "" ""
        ]
        [ (Bottle.speedToString >> text) real ]
