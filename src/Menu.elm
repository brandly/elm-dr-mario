module Menu
    exposing
        ( Msg(..)
        , State
        , init
        , view
        , update
        , subscriptions
        )

import Html exposing (Html, h3, h4, div, text, p)
import Html.Attributes exposing (style, type_)
import Html.Events exposing (onSubmit)
import Keyboard exposing (KeyCode)
import Game exposing (Speed(..))
import Element exposing (Element, styled, px)


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
    { level : Int, speed : Speed, selecting : Selection }


init : State
init =
    { level = 10, speed = Med, selecting = Level }


subscriptions : State -> Sub Msg
subscriptions _ =
    Keyboard.downs
        (\keyCode ->
            case keyCode of
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


update : { onSubmit : State -> msg } -> Msg -> State -> ( State, Maybe msg )
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
            ( s, Nothing )
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
                ( state, Just <| events.onSubmit state )

            Noop ->
                withNothing state


view : State -> Html msg
view { level, speed, selecting } =
    div
        [ style [ ( "width", "420px" ), ( "max-width", "100%" ) ] ]
        [ row []
            [ heading (selecting == Level) "virus level"
            , viewLevel level
            ]
        , row []
            [ heading (selecting == Speed) "speed"
            , div
                [ style
                    [ ( "width", "100%" )
                    , ( "display", "flex" )
                    , ( "justify-content", "space-around" )
                    ]
                ]
                ([ Low, Med, High ]
                    |> List.map (viewSpeed speed)
                )
            ]
        , btw [] [ text "use arrows, hit enter" ]
        ]


viewLevel level =
    div [ style [ ( "padding", "0 24px" ) ] ]
        [ h4 [ style [ ( "text-align", "right" ) ] ] [ (toString >> text) level ]
        , viewLevelSlider level
        ]


viewLevelSlider level =
    div
        [ style
            [ ( "display", "flex" )
            , ( "justify-content", "space-between" )
            , ( "align-items", "center" )
            ]
        ]
        (List.range 0 20
            |> List.map
                (\n ->
                    div
                        [ style
                            [ ( "height"
                              , px
                                    (if n % 5 == 0 then
                                        16
                                     else
                                        8
                                    )
                              )
                            , ( "width", "4px" )
                            , ( "background"
                              , (if n == level then
                                    "#fb7c54"
                                 else
                                    "#000"
                                )
                              )
                            ]
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


viewSpeed : a -> a -> Html msg
viewSpeed ideal real =
    h4
        [ style <|
            [ ( "padding", "4px 8px" ) ]
                ++ (if real == ideal then
                        [ ( "border", "3px solid #fb7c54" ) ]
                    else
                        []
                   )
        ]
        [ (toString >> text) real ]
