module TwoPlayer.Game exposing
    ( GameType(..)
    , Model(..)
    , Msg(..)
    , init
    , subscriptions
    , update
    , view
    )

import Bottle exposing (Color(..))
import Component
import Element exposing (Element, none, styled)
import Html exposing (Html, div, h3, p, span, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import MatchupCreator
    exposing
        ( Matchup
        , Opponent(..)
        , Player
        , Position(..)
        , mapBottle
        , mapPlayer
        )
import Speed exposing (Speed(..))


type Model
    = Prepare MatchupCreator.Model
    | Playing Matchup
    | Paused Matchup
    | Over
        { winner : Position
        , game : Matchup
        }


type Msg
    = BottleMsg BottleMsg
    | CreatorMsg MatchupCreator.Msg
    | MatchupReady Matchup
    | Bomb Position (List Color)
    | Pause
    | Resume
    | Reset


type BottleMsg
    = FirstBottleMsg Bottle.Msg
    | SecondBottleMsg Bottle.Msg


type alias Options =
    { level : Int
    , speed : Speed
    }


type GameType
    = VsHuman
    | VsBot


init : GameType -> Options -> Options -> ( Model, Cmd Msg )
init type_ first second =
    let
        opponent =
            case type_ of
                VsHuman ->
                    Human

                VsBot ->
                    Bot

        ( creator, cmd ) =
            MatchupCreator.init opponent first second
    in
    ( Prepare creator
    , Cmd.map CreatorMsg cmd
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Playing { first, second } ->
            Sub.batch
                [ Bottle.subscriptions first.speed first.bottle
                    |> Sub.map (FirstBottleMsg >> BottleMsg)
                , Bottle.subscriptions second.speed second.bottle
                    |> Sub.map (SecondBottleMsg >> BottleMsg)
                ]

        _ ->
            Sub.none



-- UPDATE --


update : { onLeave : msg } -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update { onLeave } action model =
    let
        withNothing s =
            ( s, Cmd.none, Nothing )
    in
    case ( model, action ) of
        ( Prepare creator, CreatorMsg msg ) ->
            MatchupCreator.update { onCreated = MatchupReady } msg creator
                |> Component.raiseOutMsg (update { onLeave = onLeave })
                    Prepare
                    CreatorMsg

        ( Prepare _, MatchupReady matchup ) ->
            Playing matchup |> withNothing

        ( Prepare _, _ ) ->
            model |> withNothing

        ( Playing state, Pause ) ->
            Paused state |> withNothing

        ( Paused state, Resume ) ->
            Playing state |> withNothing

        ( Paused _, _ ) ->
            model |> withNothing

        ( Playing state, Bomb receiver colors ) ->
            ( Playing <|
                mapPlayer receiver
                    (mapBottle (Bottle.withBombs colors))
                    state
            , Cmd.none
            , Nothing
            )

        ( Playing state, BottleMsg msg ) ->
            case getWinner state of
                Just winner ->
                    withNothing <|
                        Over
                            { winner = winner
                            , game = state
                            }

                Nothing ->
                    updatePlayState onLeave msg state

        ( Playing _, _ ) ->
            model |> withNothing

        ( Over _, Reset ) ->
            ( model, Cmd.none, Just onLeave )

        ( Over _, _ ) ->
            model |> withNothing


getWinner : Matchup -> Maybe Position
getWinner { first, second } =
    if Bottle.totalViruses first.bottle.contents == 0 || Bottle.hasConflict second.bottle then
        Just First

    else if Bottle.totalViruses second.bottle.contents == 0 || Bottle.hasConflict first.bottle then
        Just Second

    else
        Nothing


updatePlayState : msg -> BottleMsg -> Matchup -> ( Model, Cmd Msg, Maybe msg )
updatePlayState onLeave action ({ first, second } as model) =
    case action of
        FirstBottleMsg msg ->
            Bottle.update { onBomb = Bomb Second >> Just } msg first.bottle
                |> Component.raiseOutMsg (update { onLeave = onLeave })
                    (\bottle ->
                        Playing
                            { model | first = mapBottle (\_ -> bottle) first }
                    )
                    (FirstBottleMsg >> BottleMsg)

        SecondBottleMsg msg ->
            Bottle.update { onBomb = Bomb First >> Just } msg second.bottle
                |> Component.raiseOutMsg (update { onLeave = onLeave })
                    (\bottle ->
                        Playing
                            { model | second = mapBottle (\_ -> bottle) second }
                    )
                    (SecondBottleMsg >> BottleMsg)



-- VIEW --


view : Model -> Html Msg
view model =
    case model of
        Prepare _ ->
            div [] [ text "💊💊💊" ]

        Playing { first, second } ->
            div []
                [ div
                    [ style "display" "flex"
                    , style "flex-direction" "row"
                    ]
                    [ viewPlayer first
                    , div [ style "margin" "0 12px" ]
                        -- TODO: displays win count
                        [ h3 [] [ text "level" ]
                        , spaceBetween []
                            [ span [] [ (String.fromInt >> text) first.level ]
                            , span [] [ (String.fromInt >> text) second.level ]
                            ]
                        , h3 [] [ text "speed" ]
                        , spaceBetween []
                            [ span [] [ (Speed.toString >> text) first.speed ]
                            , span [] [ (Speed.toString >> text) second.speed ]
                            ]
                        , h3 [] [ text "virus" ]
                        , spaceBetween []
                            [ span [] [ text <| displayViruses first ]
                            , span [] [ text <| displayViruses second ]
                            ]
                        ]
                    , viewPlayer second
                    ]
                ]

        Paused _ ->
            div []
                [ viewMessage "Paused" <|
                    Html.button
                        [ onClick Resume ]
                        [ text "resume" ]
                ]

        Over state ->
            div []
                -- TODO: make it obvious which bottle won
                [ viewMessage
                    (case state.winner of
                        First ->
                            "1p wins"

                        Second ->
                            "2p wins"
                    )
                    (div [] [ Html.button [ onClick Reset ] [ text "Main Menu" ] ])
                , view (Playing state.game)
                ]


displayViruses : Player -> String
displayViruses player =
    String.fromInt (Bottle.totalViruses player.bottle.contents)


viewPlayer : Player -> Html msg
viewPlayer { bottle } =
    div
        [ style "display" "flex"
        , style "flex-direction" "column"
        , style "align-items" "center"
        ]
        [ div [ style "display" "flex", style "margin-bottom" "18px" ]
            (Bottle.viewPill bottle.next)
        , Bottle.view bottle
        ]


spaceBetween : Element msg
spaceBetween =
    styled p [ ( "display", "flex" ), ( "justify-content", "space-between" ) ]


viewMessage : String -> Html msg -> Html msg
viewMessage message below =
    div [ style "text-align" "center", style "margin" "16px 0" ]
        [ h3 [] [ text message ]
        , below
        ]
