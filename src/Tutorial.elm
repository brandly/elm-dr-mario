module Tutorial exposing (Model(..), Msg(..), init, subscriptions, update, view)

import Html exposing (Html, button, div, h1, text)
import Html.Events exposing (onClick)


type Model
    = Tutorial (List Lesson)


type Lesson
    = -- TODO: hold onto the necessary Env or whatever too
      Lesson String


init : ( Model, Cmd Msg )
init =
    ( Tutorial [ Lesson "You gotta place the pills" ], Cmd.none )


type Msg
    = OnCompletion


type alias Props msg =
    { onCompletion : msg }


update : Props msg -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update props msg model =
    case ( model, msg ) of
        ( _, OnCompletion ) ->
            ( model, Cmd.none, Just props.onCompletion )


view : Model -> Html Msg
view (Tutorial lessons) =
    div []
        (button [ onClick OnCompletion ] [ text "back" ]
            :: List.map (\(Lesson msg) -> h1 [] [ text msg ]) lessons
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
