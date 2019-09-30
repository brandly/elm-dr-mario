module Menu exposing
    ( Msg(..)
    , Selection(..)
    , State
    , init
    , subscriptions
    , update
    , view
    )

import Browser.Events exposing (onKeyDown)
import Element exposing (Element, styled)
import Html exposing (Html, div, h3, p, text)
import Html.Attributes exposing (style)
import Html.Events exposing (keyCode)
import Json.Decode as Decode


type Msg
    = Up
    | Down
    | Enter
    | Noop


type Selection
    = OnePlayer
    | TwoPlayer
    | VsBot


type alias State =
    { selection : Selection
    }


init : State
init =
    { selection = OnePlayer }


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

                    40 ->
                        Down

                    _ ->
                        Noop
            )
            keyCode
        )


update :
    { onSubmit : Selection -> msg }
    -> Msg
    -> State
    -> ( State, Cmd Msg, Maybe msg )
update events msg ({ selection } as state) =
    let
        withNothing s =
            ( s, Cmd.none, Nothing )
    in
    case ( selection, msg ) of
        ( OnePlayer, Up ) ->
            withNothing { state | selection = VsBot }

        ( OnePlayer, Down ) ->
            withNothing { state | selection = TwoPlayer }

        ( TwoPlayer, Up ) ->
            withNothing { state | selection = OnePlayer }

        ( TwoPlayer, Down ) ->
            withNothing { state | selection = VsBot }

        ( VsBot, Up ) ->
            withNothing { state | selection = TwoPlayer }

        ( VsBot, Down ) ->
            withNothing { state | selection = OnePlayer }

        ( _, Enter ) ->
            ( state
            , Cmd.none
            , Just <| events.onSubmit selection
            )

        ( _, Noop ) ->
            withNothing state


view : State -> Html msg
view { selection } =
    div
        [ style "width" "420px"
        , style "max-width" "100%"
        , style "text-align" "center"
        ]
        [ heading (selection == OnePlayer) "1Player Game"
        , heading (selection == TwoPlayer) "2Player Game"
        , heading (selection == VsBot) "vs. Com"
        , btw [] [ text "use arrows, hit enter" ]
        ]


btw : Element msg
btw =
    styled p
        [ ( "font-color", "#666" )
        , ( "text-align", "center" )
        ]


heading : Bool -> String -> Html msg
heading selected str =
    h3 []
        [ text <|
            if selected then
                ">" ++ str ++ "<"

            else
                str
        ]
