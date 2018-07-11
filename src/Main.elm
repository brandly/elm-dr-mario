module Main exposing (..)

import Html exposing (Html, h1, text, div)
import Html.Attributes exposing (style)
import Random
import Element exposing (Element, px, styled)
import Grid exposing (Cell, Color(..), Type(..), Column, Grid)
import Time exposing (Time, second)
import Keyboard exposing (KeyCode)
import Random exposing (Generator)


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
    , mode = Fall
    }


type Msg
    = TickTock Time
    | KeyChange Bool KeyCode
    | RandomPill ( Color, Color )


randomColor : Generator Color
randomColor =
    selectWithDefault Blue [ Red, Yellow, Blue ]


selectWithDefault : a -> List a -> Generator a
selectWithDefault defaultValue list =
    Random.map (Maybe.withDefault defaultValue) (randomSelect list)


randomSelect : List a -> Generator (Maybe a)
randomSelect list =
    Random.map (\index -> randomGet index list)
        (Random.int 0 (List.length list - 1))


randomGet : Int -> List a -> Maybe a
randomGet index list =
    if index < 0 then
        Nothing
    else
        case List.drop index list of
            [] ->
                Nothing

            x :: xs ->
                Just x


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        TickTock _ ->
            case model.mode of
                Init ->
                    ( model, Cmd.none )

                Pill pill ( x, y ) ->
                    let
                        newPair =
                            ( x, y + 1 )
                    in
                        ( if isAvailable newPair pill model.bottle then
                            { model | mode = Pill pill newPair }
                          else
                            afterPill pill ( x, y ) model
                        , Cmd.none
                        )

                Fall ->
                    let
                        timeToFall : Bool
                        timeToFall =
                            model.bottle
                                |> Grid.filter
                                    (\{ x, y } -> canFall ( x, y ) model.bottle)
                                |> (List.length >> (<) 0)
                    in
                        if timeToFall then
                            ( { model
                                | mode = Fall
                                , bottle =
                                    fall model.bottle
                              }
                            , Cmd.none
                            )
                        else if canSweep model.bottle then
                            ( { model | bottle = sweep model.bottle }, Cmd.none )
                        else
                            ( { model | mode = Init }
                            , Random.generate RandomPill <|
                                Random.map2 (,) randomColor randomColor
                            )

        RandomPill ( a, b ) ->
            ( { model | mode = Pill (Horizontal a b) ( 4, 1 ) }, Cmd.none )

        KeyChange True code ->
            let
                moveIfAvailable pill pair =
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
                                    moveIfAvailable newPill ( x, y )

                            37 ->
                                moveIfAvailable pill ( x - 1, y )

                            39 ->
                                moveIfAvailable pill ( x + 1, y )

                            40 ->
                                moveIfAvailable pill ( x, y + 1 )

                            _ ->
                                ( model, Cmd.none )

                    _ ->
                        ( model, Cmd.none )

        KeyChange False _ ->
            ( model, Cmd.none )


afterPill : Pill -> Grid.Pair -> Model -> Model
afterPill pill pair model =
    let
        newBottle =
            addPill pill pair model.bottle
    in
        { model
            | mode = Fall
            , bottle =
                if canSweep newBottle then
                    sweep newBottle
                else
                    fall newBottle
        }


canSweep : Grid -> Bool
canSweep grid =
    grid
        |> Grid.filter
            (\({ x, y } as cell) ->
                isCleared ( x, y ) grid
            )
        |> (List.length >> (<) 0)


sweep : Grid -> Grid
sweep bottle =
    Grid.map
        (\({ x, y } as cell) ->
            if isCleared ( x, y ) bottle then
                { cell | state = Nothing }
            else
                cell
        )
        bottle


canFall : Grid.Pair -> Grid -> Bool
canFall pair bottle =
    let
        cell =
            Grid.findCellAtPair pair bottle

        hasRoom : List Cell -> Bool
        hasRoom cells =
            case cells of
                [] ->
                    False

                head :: tail ->
                    case head.state of
                        Nothing ->
                            True

                        Just ( _, Grid.Pill ) ->
                            hasRoom tail

                        Just ( _, Virus ) ->
                            False
    in
        case cell.state of
            Just ( _, Grid.Pill ) ->
                (Grid.below pair bottle |> hasRoom)

            _ ->
                False


fall : Grid -> Grid
fall bottle =
    Grid.map
        (\({ x, y, state } as cell) ->
            if canFall ( x, y ) bottle then
                -- look above
                if canFall ( x, y - 1 ) bottle then
                    { cell
                        | state =
                            .state <| Grid.findCellAtPair ( x, y - 1 ) bottle
                    }
                else
                    { cell | state = Nothing }
            else if state == Nothing && canFall ( x, y - 1 ) bottle then
                { cell
                    | state =
                        .state <|
                            Grid.findCellAtPair ( x, y - 1 ) bottle
                }
            else
                cell
        )
        bottle


isCleared : Grid.Pair -> Grid -> Bool
isCleared ( x, y ) grid =
    let
        cell =
            Grid.findCellAtPair ( x, y ) grid

        horizontal : List (List Cell)
        horizontal =
            [ ( x - 3, y ), ( x - 2, y ), ( x - 1, y ), ( x, y ), ( x + 1, y ), ( x + 2, y ), ( x + 3, y ) ]
                |> List.map
                    (\pair -> Grid.findCellAtPair pair grid)
                |> subLists 4

        vertical : List (List Cell)
        vertical =
            [ ( x, y - 3 ), ( x, y - 2 ), ( x, y - 1 ), ( x, y ), ( x, y + 1 ), ( x, y + 2 ), ( x, y + 3 ) ]
                |> List.map
                    (\pair -> Grid.findCellAtPair pair grid)
                |> subLists 4
    in
        case cell.state of
            Nothing ->
                False

            Just ( color, _ ) ->
                List.any
                    (List.all
                        (\cell ->
                            case cell.state of
                                Just ( c, _ ) ->
                                    c == color

                                Nothing ->
                                    False
                        )
                    )
                    (vertical ++ horizontal)


subLists : Int -> List a -> List (List a)
subLists len list =
    if List.length list < len then
        []
    else
        (List.take len list) :: subLists len (List.drop 1 list)


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
            [ h1 [] [ text "dr. mario 💊" ]
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
