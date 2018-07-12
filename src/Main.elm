module Main exposing (..)

import Html exposing (Html, h1, h3, text, div, p)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Element exposing (Element, px, styled)
import Grid exposing (Cell, Color(..), Type(..), Column, Grid)
import Time exposing (Time, second)
import Keyboard exposing (KeyCode)
import Random exposing (Generator)


main : Program Never Model Msg
main =
    Html.program
        { init = ( Init, Cmd.none )
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Pill
    = Horizontal Color Color
    | Vertical Color Color


type PlayMode
    = Pill Pill Grid.Pair
    | Fall


type Speed
    = Low
    | Med
    | High


type Model
    = Init
    | PrepareGame
        { level : Int
        , score : Int
        , bottle : Grid
        }
    | Play PlayState
    | Over
        { won : Bool
        , bottle : Grid
        , level : Int
        , score : Int
        }


type alias PlayState =
    { bottle : Grid
    , mode : PlayMode
    , next : ( Color, Color )
    , level : Int
    , score : Int
    }


type Msg
    = TickTock Time
    | KeyChange Bool KeyCode
    | NewPill ( Color, Color )
    | Begin { level : Int, score : Int }
    | NewVirus ( Color, Grid.Pair )
    | Reset


emptyBottle : Grid
emptyBottle =
    Grid.fromDimensions ( 8, 16 )


pairsForPill : Pill -> Grid.Pair -> List Grid.Pair
pairsForPill pill ( x, y ) =
    case pill of
        Horizontal _ _ ->
            [ ( x, y + 1 ), ( x + 1, y + 1 ) ]

        Vertical _ _ ->
            [ ( x, y ), ( x, y + 1 ) ]


randomColor : Generator Color
randomColor =
    selectWithDefault Blue [ Red, Yellow, Blue ]


randomNewVirus : Grid -> Cmd Msg
randomNewVirus bottle =
    Random.generate NewVirus <|
        Random.pair randomColor (randomEmptyPair bottle)


randomNewPill : Cmd Msg
randomNewPill =
    Random.generate NewPill <|
        Random.pair randomColor randomColor


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
        selectWithDefault ( -1, -1 ) emptyPairs


selectWithDefault : a -> List a -> Generator a
selectWithDefault defaultValue list =
    let
        get : Int -> List a -> Maybe a
        get index list =
            if index < 0 then
                Nothing
            else
                case List.drop index list of
                    [] ->
                        Nothing

                    x :: xs ->
                        Just x

        select : List a -> Generator (Maybe a)
        select list =
            Random.map (\index -> get index list)
                (Random.int 0 (List.length list - 1))
    in
        Random.map (Maybe.withDefault defaultValue) (select list)


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
                , bottle = emptyBottle
                }
            , randomNewVirus emptyBottle
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
                if isCleared pair newBottle then
                    -- would create a 4-in-a-row, so let's try a new virus
                    ( PrepareGame state, randomNewVirus bottle )
                else if Grid.totalViruses newBottle >= desiredCount then
                    ( PrepareGame { state | bottle = newBottle }
                    , randomNewPill
                    )
                else
                    ( PrepareGame { state | bottle = newBottle }
                    , randomNewVirus newBottle
                    )

        ( PrepareGame { level, bottle, score }, NewPill colors ) ->
            ( Play
                { bottle = bottle
                , mode = Fall
                , next = colors
                , level = level
                , score = score
                }
            , Cmd.none
            )

        ( Play state, _ ) ->
            if Grid.totalViruses state.bottle == 0 then
                ( Over
                    { won = True
                    , bottle = state.bottle
                    , level = state.level
                    , score = state.score
                    }
                , Cmd.none
                )
            else
                let
                    lossed =
                        case state.mode of
                            Pill pill pair ->
                                pairsForPill pill pair
                                    |> List.map (\p -> Grid.isEmpty p state.bottle)
                                    |> (List.all Basics.identity >> not)

                            _ ->
                                False

                    ( newPlayState, cmd ) =
                        updatePlayState action state
                in
                    if lossed then
                        ( Over
                            { won = False
                            , bottle = state.bottle
                            , level = state.level
                            , score = state.score
                            }
                        , Cmd.none
                        )
                    else
                        ( Play newPlayState, cmd )

        ( Over _, Reset ) ->
            ( Init, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


updatePlayState : Msg -> PlayState -> ( PlayState, Cmd Msg )
updatePlayState action model =
    case action of
        TickTock _ ->
            case model.mode of
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
                                |> (List.isEmpty >> not)
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
                            ( sweep model, Cmd.none )
                        else
                            ( model, randomNewPill )

        NewPill next ->
            let
                ( a, b ) =
                    model.next
            in
                ( { model
                    | mode = Pill (Horizontal a b) ( 4, 0 )
                    , next = next
                  }
                , Cmd.none
                )

        KeyChange True code ->
            let
                moveIfAvailable : Pill -> Grid.Pair -> ( PlayState, Cmd Msg )
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

        -- TODO: types should be better so we don't list these here
        Begin _ ->
            ( model, Cmd.none )

        Reset ->
            ( model, Cmd.none )

        NewVirus _ ->
            ( model, Cmd.none )


afterPill : Pill -> Grid.Pair -> PlayState -> PlayState
afterPill pill pair model =
    let
        newBottle =
            addPill pill pair model.bottle

        modify =
            if canSweep newBottle then
                sweep
            else
                (\m -> { m | bottle = fall newBottle })
    in
        modify
            { model
                | mode = Fall
                , bottle = newBottle
            }


pointsForClearedViruses : Speed -> Int -> Int
pointsForClearedViruses speed cleared =
    applyNtimes (cleared - 1)
        ((*) 2)
        (case speed of
            Low ->
                100

            Med ->
                200

            High ->
                300
        )


applyNtimes : Int -> (a -> a) -> a -> a
applyNtimes n f x =
    if n <= 0 then
        x
    else if n == 1 then
        f x
    else
        f (applyNtimes (n - 1) f x)


canSweep : Grid -> Bool
canSweep grid =
    sweepableCount grid > 0


sweepableCount : Grid -> Int
sweepableCount grid =
    grid
        |> Grid.filter
            (\({ x, y } as cell) ->
                isCleared ( x, y ) grid
            )
        |> (List.length)


sweepableVirusCount : Grid -> Int
sweepableVirusCount grid =
    grid
        |> Grid.filter
            (\({ x, y, state } as cell) ->
                case state of
                    Just ( _, Virus ) ->
                        isCleared ( x, y ) grid

                    _ ->
                        False
            )
        |> (List.length)


sweep : PlayState -> PlayState
sweep ({ bottle, score } as model) =
    let
        sweptBottle =
            Grid.map
                (\({ x, y } as cell) ->
                    if isCleared ( x, y ) bottle then
                        { cell | state = Nothing }
                    else
                        cell
                )
                bottle

        additionalPoints =
            (sweepableVirusCount >> (pointsForClearedViruses Med)) bottle
    in
        { model | bottle = sweptBottle, score = score + additionalPoints }


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

        len =
            4

        horizontal : List (List Cell)
        horizontal =
            neighbors (\offset -> ( x + offset, y ))

        vertical : List (List Cell)
        vertical =
            neighbors (\offset -> ( x, y + offset ))

        neighbors f =
            List.range (len * -1 + 1) (len - 1)
                |> List.map f
                |> List.map (\pair -> Grid.findCellAtPair pair grid)
                |> subLists len
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
isAvailable (( x, y ) as pair) pill grid =
    let
        aboveBottom =
            y < Grid.height grid

        withinRight =
            case pill of
                Vertical _ _ ->
                    x <= Grid.width grid

                Horizontal _ _ ->
                    x < Grid.width grid

        inBottle =
            (x >= 1)
                && withinRight
                && aboveBottom

        noOccupant =
            pairsForPill pill pair
                |> List.map (\p -> Grid.isEmpty p grid)
                |> List.all Basics.identity
    in
        inBottle && noOccupant


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        time =
            Time.every (700 * Time.millisecond) TickTock

        keys =
            [ Keyboard.downs (KeyChange True)
            , Keyboard.ups (KeyChange False)
            ]
    in
        case model of
            Play _ ->
                Sub.batch (time :: keys)

            _ ->
                Sub.none


colorPairs : Pill -> Grid.Pair -> List ( Color, Grid.Pair )
colorPairs pill pair =
    let
        ( a, b ) =
            case pill of
                Horizontal a b ->
                    ( a, b )

                Vertical a b ->
                    ( a, b )
    in
        case pairsForPill pill pair of
            first :: second :: [] ->
                [ ( a, first ), ( b, second ) ]

            _ ->
                []


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

            Play state ->
                div [ style [ ( "display", "flex" ) ] ]
                    [ viewBottle
                        (case state.mode of
                            Pill pill pair ->
                                addPill pill pair state.bottle

                            _ ->
                                state.bottle
                        )
                    , div [ style [ ( "margin", "16px" ) ] ]
                        [ h3 [] [ text "next" ]
                        , div [ style [ ( "display", "flex" ) ] ]
                            [ (Tuple.first >> viewPill) state.next
                            , (Tuple.second >> viewPill) state.next
                            ]
                        , h3 [] [ text "level" ]
                        , p [] [ (toString >> text) state.level ]
                        , h3 [] [ text "virus" ]
                        , p [] [ text <| toString (Grid.totalViruses state.bottle) ]
                        , h3 [] [ text "score" ]
                        , p [] [ (toString >> text) state.score ]
                        ]
                    ]

            Over state ->
                div []
                    [ h1 []
                        [ text
                            (if state.won then
                                "you won!"
                             else
                                "Game Over"
                            )
                        ]
                    , if state.won then
                        Html.button
                            [ onClick
                                (Begin
                                    { level = (state.level + 1)
                                    , score = state.score
                                    }
                                )
                            ]
                            [ text "Next Level" ]
                      else
                        text ""
                    , Html.button [ onClick Reset ] [ text "Main Menu" ]
                    , viewBottle state.bottle
                    ]
        ]


viewBottle : Grid -> Html Msg
viewBottle bottle =
    div []
        [ div
            [ style
                [ ( "display", "inline-block" )
                , ( "border", "3px solid #CCC" )
                , ( "border-radius", "3px" )
                , ( "background", "#000" )
                ]
            ]
            (List.map
                (\column ->
                    div
                        [ style [ ( "display", "inline-block" ), ( "vertical-align", "top" ) ] ]
                        (List.map
                            (\cell ->
                                case cell.state of
                                    Nothing ->
                                        div [ style cellStyle ] []

                                    Just ( color, Grid.Pill ) ->
                                        viewPill color

                                    Just ( color, Grid.Virus ) ->
                                        viewVirus color
                            )
                            column
                        )
                )
                bottle
            )
        ]


viewPill : Color -> Html msg
viewPill color =
    viewColor color []


viewVirus : Color -> Html msg
viewVirus color =
    viewColor color [ text "◔̯◔" ]


viewColor : Color -> List (Html msg) -> Html msg
viewColor color =
    let
        bg =
            case color of
                Red ->
                    "#e8005a"

                Blue ->
                    "#39bdff"

                Yellow ->
                    "#ffbd03"
    in
        div
            [ style
                ([ ( "background-color", bg )
                 , ( "border-radius", "3px" )
                 ]
                    ++ cellStyle
                )
            ]


cellStyle : List ( String, String )
cellStyle =
    [ ( "width", px cellSize )
    , ( "height", px cellSize )
    , ( "border", "1px solid black" )
    ]


cellSize : Int
cellSize =
    24
