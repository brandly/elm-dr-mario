module Main exposing (..)

import Html exposing (Html, h1, h3, text, div, p, input)
import Html.Attributes exposing (style, type_)
import Html.Events exposing (onClick, onSubmit)
import Grid exposing (Cell, Type(..), Column, Grid)
import Time exposing (Time, second)
import Random exposing (Generator)
import Menu
import Game exposing (Speed(..))
import Virus exposing (Color(..))
import RandomExtra


main : Program Never Model Msg
main =
    Html.program
        { init = ( Init Menu.init, Cmd.none )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Model
    = Init Menu.State
    | PrepareGame
        { level : Int
        , score : Int
        , bottle : Grid
        , speed : Speed
        }
    | Playing Game.State
    | Paused Game.State
    | Over
        { won : Bool
        , game : Game.State
        }


type Msg
    = Begin { level : Int, score : Int, speed : Speed }
    | NewVirus ( Color, Grid.Pair )
    | InitPill ( Color, Color )
    | MenuMsg Menu.Msg
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


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case ( model, action ) of
        ( _, Begin { level, score, speed } ) ->
            ( PrepareGame
                { level = level
                , score = score
                , bottle = Game.emptyBottle
                , speed = speed
                }
            , randomNewVirus Game.emptyBottle
            )

        ( PrepareGame ({ level, score, bottle } as state), NewVirus ( color, pair ) ) ->
            let
                newBottle =
                    Grid.updateCellsAtPairs
                        (\c -> { c | state = Just ( color, Virus ) })
                        [ pair ]
                        bottle
            in
                if Game.isCleared pair newBottle then
                    -- would create a 4-in-a-row, so let's try a new virus
                    ( PrepareGame state, randomNewVirus bottle )
                else if Grid.totalViruses newBottle >= Game.virusesForLevel level then
                    ( PrepareGame { state | bottle = newBottle }
                    , Random.generate InitPill <|
                        Game.randomNewPill
                    )
                else
                    ( PrepareGame { state | bottle = newBottle }
                    , randomNewVirus newBottle
                    )

        ( PrepareGame { level, bottle, score, speed }, InitPill colors ) ->
            ( (Game.init >> Playing)
                { level = level
                , bottle = bottle
                , score = score
                , colors = colors
                , speed = speed
                }
            , Cmd.none
            )

        ( Playing state, Pause ) ->
            ( Paused state, Cmd.none )

        ( Paused state, Resume ) ->
            ( Playing state, Cmd.none )

        ( Init state, MenuMsg msg ) ->
            ( Init (Menu.update msg state), Cmd.none )

        ( Playing state, PlayMsg msg ) ->
            if Grid.totalViruses state.bottle == 0 then
                ( Over
                    { won = True
                    , game = state
                    }
                , Cmd.none
                )
            else if Game.isOver state then
                ( Over
                    { won = False
                    , game = state
                    }
                , Cmd.none
                )
            else
                Game.update msg state
                    |> Tuple.mapFirst Playing
                    |> Tuple.mapSecond (Cmd.map PlayMsg)

        ( Over _, Reset ) ->
            ( Init Menu.init, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Playing state ->
            Sub.map PlayMsg <| Game.subscriptions state

        _ ->
            Sub.none


view : Model -> Html Msg
view model =
    div [ style [ ( "display", "flex" ), ( "flex-direction", "column" ), ( "align-items", "center" ) ] ]
        [ h1 [] [ text "dr. mario 💊" ]
        , case model of
            Init state ->
                state
                    |> (Menu.view >> List.map (Html.map MenuMsg))
                    |> (\fields ->
                            fields
                                ++ [ input [ style [ ( "margin", "16px 0" ) ], type_ "submit" ] []
                                   ]
                       )
                    |> Html.form
                        [ onSubmit
                            (Begin
                                { level = state.level
                                , speed = state.speed
                                , score = 0
                                }
                            )
                        ]

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
                                            { speed = state.game.speed
                                            , level = (state.game.level + 1)
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
