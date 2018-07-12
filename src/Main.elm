module Main exposing (..)

import Html exposing (Html, h1, h3, text, div, p)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Grid exposing (Cell, Type(..), Column, Grid)
import Time exposing (Time, second)
import Random exposing (Generator)
import Game
import Virus exposing (Color(..))
import RandomExtra


main : Program Never Model Msg
main =
    Html.program
        { init = ( Init, Cmd.none )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Model
    = Init
    | PrepareGame
        { level : Int
        , score : Int
        , bottle : Grid
        }
    | Playing Game.State
    | Paused Game.State
    | Over
        { won : Bool
        , game : Game.State
        }


type Msg
    = Begin { level : Int, score : Int }
    | NewVirus ( Color, Grid.Pair )
    | InitPill ( Color, Color )
    | PlayMsg Game.Msg
    | Pause
    | Resume
    | Reset


randomNewVirus : Grid -> Cmd Msg
randomNewVirus bottle =
    Random.generate NewVirus <|
        Random.pair Virus.generateColor (randomEmptyPair bottle)


randomEmptyPair : Grid -> Generator Grid.Pair
randomEmptyPair grid =
    let
        emptyPairs : List ( Int, Int )
        emptyPairs =
            Grid.filter
                (\{ x, y } ->
                    y >= 5 && (Grid.isEmpty ( x, y ) grid)
                )
                grid
                |> List.map (\{ x, y } -> ( x, y ))
    in
        RandomExtra.selectWithDefault ( -1, -1 ) emptyPairs


virusesForLevel : Int -> Int
virusesForLevel level =
    -- TODO: better types?
    if level <= 20 then
        4 * level + 4
    else
        84


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case ( model, action ) of
        ( _, Begin { level, score } ) ->
            ( PrepareGame
                { level = level
                , score = score
                , bottle = Game.emptyBottle
                }
            , randomNewVirus Game.emptyBottle
            )

        ( PrepareGame ({ level, score, bottle } as state), NewVirus ( color, pair ) ) ->
            let
                desiredCount =
                    virusesForLevel level

                newBottle =
                    Grid.updateCellsAtPairs
                        (\c -> { c | state = Just ( color, Virus ) })
                        [ pair ]
                        bottle
            in
                if Game.isCleared pair newBottle then
                    -- would create a 4-in-a-row, so let's try a new virus
                    ( PrepareGame state, randomNewVirus bottle )
                else if Grid.totalViruses newBottle >= desiredCount then
                    ( PrepareGame { state | bottle = newBottle }
                    , Random.generate InitPill <|
                        Game.randomNewPill
                    )
                else
                    ( PrepareGame { state | bottle = newBottle }
                    , randomNewVirus newBottle
                    )

        ( PrepareGame { level, bottle, score }, InitPill colors ) ->
            ( (Game.init >> Playing)
                { level = level
                , bottle = bottle
                , score = score
                , colors = colors
                }
            , Cmd.none
            )

        ( Playing state, Pause ) ->
            ( Paused state, Cmd.none )

        ( Paused state, Resume ) ->
            ( Playing state, Cmd.none )

        ( Playing state, PlayMsg msg ) ->
            if Grid.totalViruses state.bottle == 0 then
                ( Over
                    { won = True
                    , game = state
                    }
                , Cmd.none
                )
            else
                let
                    ( newPlayState, cmd ) =
                        Game.update msg state
                in
                    if Game.isOver state then
                        ( Over
                            { won = False
                            , game = state
                            }
                        , Cmd.none
                        )
                    else
                        ( Playing newPlayState, Cmd.map PlayMsg cmd )

        ( Over _, Reset ) ->
            ( Init, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Playing _ ->
            Sub.map PlayMsg <| Game.subscriptions

        _ ->
            Sub.none


view : Model -> Html Msg
view model =
    div [ style [ ( "display", "flex" ), ( "flex-direction", "column" ), ( "align-items", "center" ) ] ]
        [ h1 [] [ text "dr. mario 💊" ]
        , case model of
            Init ->
                (h3 [] [ text "starting level" ])
                    :: ((List.range 0 20)
                            |> List.map
                                (\level ->
                                    Html.button
                                        [ onClick (Begin { level = level, score = 0 }) ]
                                        [ (toString >> text) level ]
                                )
                       )
                    |> div []

            PrepareGame _ ->
                div [] [ text "💊💊💊" ]

            Playing state ->
                Game.view (Just Pause) state

            Paused state ->
                div []
                    [ viewMessage "Paused"
                        (Html.button
                            [ onClick Resume ]
                            [ text "resume" ]
                        )
                    ]

            Over state ->
                div []
                    [ viewMessage
                        (if state.won then
                            "You Win!"
                         else
                            "Game Over"
                        )
                        (div []
                            [ (if state.won then
                                Html.button
                                    [ onClick
                                        (Begin
                                            { level = (state.game.level + 1)
                                            , score = state.game.score
                                            }
                                        )
                                    ]
                                    [ text "Next Level" ]
                               else
                                text ""
                              )
                            , Html.button [ onClick Reset ] [ text "Main Menu" ]
                            ]
                        )
                    , Game.view Nothing state.game
                    ]
        ]


viewMessage : String -> Html msg -> Html msg
viewMessage message below =
    div [ style [ ( "text-align", "center" ), ( "margin", "16px 0" ) ] ]
        [ h3 [] [ text message ]
        , below
        ]
