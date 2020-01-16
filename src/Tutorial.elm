module Tutorial exposing (Model(..), Msg(..), init, subscriptions, update, view)

import Html exposing (Html, div, h1, text)


type Model
    = Tutorial


init : ( Model, Cmd Msg )
init =
    ( Tutorial, Cmd.none )


type Msg
    = Advance


type alias Props msg =
    { onCompletion : msg }


update : Props msg -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update props msg model =
    ( model, Cmd.none, Nothing )


view : Model -> Html msg
view model =
    h1 [] [ text "hi" ]


subscriptions model =
    Sub.none
