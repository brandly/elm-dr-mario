module Main exposing (..)

import Html exposing (Html, h1, text, div)
import Html.Attributes exposing (style)
import Random
import Element exposing (Element, px, styled)
import Grid exposing (Cell, Color(..), Type(..), Column, Grid)
import Time exposing (Time, second)
import Keyboard exposing (KeyCode)


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Pill
    = Horizontal Color Color
    | Vertical Color Color


type Mode
    = Init
    | Pill Pill Grid.Pair
    | Sweep
    | Fall


type alias Model =
    { bottle : Grid
    , mode : Mode
    }


initialModel : Model
initialModel =
    { bottle =
        Grid.fromDimensions ( 8, 16 )
            |> Grid.updateCellsAtPairs
                (\cell -> { cell | state = Just ( Blue, Virus ) })
                [ ( 1, 8 ), ( 1, 12 ), ( 5, 12 ) ]
            |> Grid.updateCellsAtPairs
                (\cell -> { cell | state = Just ( Red, Virus ) })
                [ ( 1, 9 ), ( 2, 8 ), ( 4, 13 ), ( 4, 14 ) ]
            |> Grid.updateCellsAtPairs
                (\cell -> { cell | state = Just ( Yellow, Virus ) })
                [ ( 1, 7 ), ( 1, 11 ), ( 6, 16 ) ]
    , mode = Init
    }


type Msg
    = TickTock Time
    | KeyChange Bool KeyCode


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        TickTock _ ->
            case model.mode of
                Init ->
                    -- TODO: random pill
                    ( { model | mode = Pill (Vertical Blue Red) ( 4, 1 ) }, Cmd.none )

                Pill pill ( x, y ) ->
                    let
                        newPair =
                            ( x, y + 1 )
                    in
                        ( if isAvailable newPair pill model.bottle then
                            { model | mode = Pill pill newPair }
                          else
                            { model
                              -- TODO: send into Fall
                                | mode = Pill (Vertical Blue Red) ( 4, 1 )
                                , bottle =
                                    addPill pill ( x, y ) model.bottle
                            }
                        , Cmd.none
                        )

                -- TODO: fall
                _ ->
                    ( model, Cmd.none )

        KeyChange True code ->
            let
                setIfAvailable pill pair =
                    if isAvailable pair pill model.bottle then
                        ( { model | mode = Pill pill pair }, Cmd.none )
                    else
                        ( model, Cmd.none )
            in
                case model.mode of
                    Pill pill ( x, y ) ->
                        case code of
                            38 ->
                                let
                                    newPill =
                                        case pill of
                                            Horizontal a b ->
                                                Vertical a b

                                            Vertical a b ->
                                                Horizontal b a
                                in
                                    setIfAvailable newPill ( x, y )

                            37 ->
                                setIfAvailable pill ( x - 1, y )

                            39 ->
                                setIfAvailable pill ( x + 1, y )

                            40 ->
                                setIfAvailable pill ( x, y + 1 )

                            _ ->
                                ( model, Cmd.none )

                    _ ->
                        ( model, Cmd.none )

        KeyChange False _ ->
            ( model, Cmd.none )


isAvailable : Grid.Pair -> Pill -> Grid -> Bool
isAvailable ( x, y ) pill grid =
    let
        aboveBottom =
            case pill of
                Vertical _ _ ->
                    y < Grid.height grid

                Horizontal _ _ ->
                    y <= Grid.height grid

        inBottle =
            (x >= 1)
                && (x <= Grid.width grid)
                && aboveBottom

        noViruses =
            case pill of
                Horizontal _ _ ->
                    Grid.isEmpty ( x, y ) grid
                        && Grid.isEmpty ( x + 1, y ) grid

                Vertical _ _ ->
                    Grid.isEmpty ( x, y ) grid
                        && Grid.isEmpty ( x, y + 1 ) grid
    in
        inBottle && noViruses


subscriptions : Model -> Sub Msg
subscriptions _ =
    let
        time =
            Time.every Time.second TickTock

        keys =
            [ Keyboard.downs (KeyChange True)
            , Keyboard.ups (KeyChange False)
            ]
    in
        Sub.batch (time :: keys)


colorPairs : Pill -> Grid.Pair -> List ( Color, Grid.Pair )
colorPairs pill pair =
    case ( pill, pair ) of
        ( Horizontal a b, ( x, y ) ) ->
            [ ( a, ( x, y ) ), ( b, ( x + 1, y ) ) ]

        ( Vertical a b, ( x, y ) ) ->
            [ ( a, ( x, y ) ), ( b, ( x, y + 1 ) ) ]


addPill : Pill -> Grid.Pair -> Grid -> Grid
addPill pill pair bottle =
    colorPairs pill pair
        |> List.foldl
            (\( color, pair ) grid ->
                Grid.updateCellsAtPairs
                    (\c -> { c | state = Just ( color, Grid.Pill ) })
                    [ pair ]
                    grid
            )
            bottle


view : Model -> Html Msg
view { bottle, mode } =
    let
        withPill : Grid
        withPill =
            case mode of
                Pill pill pair ->
                    addPill pill pair bottle

                _ ->
                    bottle
    in
        div []
            [ h1 [] [ text "dr. mario" ]
            , (div
                [ style [ ( "display", "inline-block" ) ] ]
                (List.map
                    (\column ->
                        div
                            [ style [ ( "display", "inline-block" ) ] ]
                            (List.map
                                (\cell ->
                                    case cell.state of
                                        Nothing ->
                                            div [ style cellStyle ] []

                                        Just ( color, _ ) ->
                                            viewColor color
                                )
                                column
                            )
                    )
                    withPill
                )
              )
            ]


viewColor : Color -> Html msg
viewColor color =
    let
        bg =
            case color of
                Red ->
                    "#f44336"

                Blue ->
                    "#0383f4"

                Yellow ->
                    "#ffed5e"
    in
        div [ style (( "background-color", bg ) :: cellStyle) ] []


cellStyle : List ( String, String )
cellStyle =
    [ ( "width", px cellSize )
    , ( "height", px cellSize )
    , ( "border-right", "1px solid #DDD" )
    , ( "border-bottom", "1px solid #DDD" )
    ]


cellSize : Int
cellSize =
    16
