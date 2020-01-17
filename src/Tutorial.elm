module Tutorial exposing (Model(..), Msg(..), init, subscriptions, update, view)

import Html exposing (Html, button, div, h1, text)
import Html.Events exposing (onClick)


type Model
    = Tutorial


init : ( Model, Cmd Msg )
init =
    ( Tutorial, Cmd.none )


type Msg
    = Advance
    | OnCompletion


type alias Props msg =
    { onCompletion : msg }


update : Props msg -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update props msg model =
    case ( model, msg ) of
        ( _, OnCompletion ) ->
            ( model, Cmd.none, Just props.onCompletion )

        ( _, _ ) ->
            ( model, Cmd.none, Nothing )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "hi" ]
        , button [ onClick OnCompletion ] [ text "back" ]
        ]


subscriptions model =
    Sub.none
