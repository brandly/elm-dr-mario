module Bottle
    exposing
        ( Bottle
        , Color(..)
        , Direction(..)
        , Model
        , Msg(..)
        , Speed(..)
        , generateColor
        , generateEmptyCoords
        , generatePill
        , hasConflict
        , init
        , isCleared
        , subscriptions
        , totalViruses
        , update
        , view
        , viewPill
        , withBombs
        , withControls
        , withNext
        , withVirus
        , speedToString
        )

import Element exposing (Element, none, px, styled)
import Grid exposing (Cell, Column, Grid)
import Html exposing (Html, div, h1, h3, p, text)
import Html.Attributes exposing (style)
import Html.Events exposing (keyCode)
import Browser.Events exposing (onKeyDown)
import Random exposing (Generator(..))
import RandomExtra exposing (selectWithDefault)
import Set
import Time exposing (Posix)
import Json.Decode as Decode


type Speed
    = Low
    | Med
    | High


speedToString : Speed -> String
speedToString s =
    case s of
        Low ->
            "Low"

        Med ->
            "Med"

        High ->
            "High"


type Controls
    = Keyboard (Int -> Maybe Direction)
    | Bot (Bottle -> Mode -> Maybe Direction)


type Mode
    = PlacingPill Pill Grid.Coords
    | Falling (List Color)
    | Bombing


type Pill
    = Horizontal Color Color
    | Vertical Color Color


type Type
    = Virus
    | Pill (Maybe Dependent)


type alias Dependent =
    Direction


type Color
    = Red
    | Blue
    | Yellow


type alias Contents =
    ( Color, Type )


type alias Bottle =
    Grid Contents


type alias Model =
    { contents : Bottle
    , mode : Mode
    , next : ( Color, Color )
    , controls : Controls
    , bombs : List Color
    }


init : Model
init =
    { contents = Grid.fromDimensions 8 16
    , mode = Falling []
    , next = ( Red, Red )
    , controls = Bot trashBot
    , bombs = []
    }


trashBot : Bottle -> Mode -> Maybe Direction
trashBot bottle mode =
    case mode of
        Falling _ ->
            Nothing

        Bombing ->
            Nothing

        PlacingPill pill coords ->
            let
                flip : Maybe Direction
                flip =
                    -- if colors are different, go horizontal
                    -- otherwise, vertical
                    case pill of
                        Horizontal a b ->
                            if a == b then
                                Just Up
                            else
                                Nothing

                        Vertical a b ->
                            if a == b then
                                Nothing
                            else
                                Just Up
            in
                case flip of
                    Just _ ->
                        flip

                    Nothing ->
                        let
                            -- paying no attention to secondary color
                            ( color_a, color_b ) =
                                case pill of
                                    Vertical a b ->
                                        ( a, b )

                                    Horizontal a b ->
                                        ( a, b )

                            peaks : List (Grid.Cell Contents)
                            peaks =
                                bottle
                                    |> List.map
                                        (\column ->
                                            column
                                                |> List.filter
                                                    (\cell ->
                                                        case cell.state of
                                                            Just _ ->
                                                                True

                                                            Nothing ->
                                                                False
                                                    )
                                                |> List.head
                                        )
                                    |> List.filterMap identity

                            firstMatch : Color -> Maybe ( Int, Int )
                            firstMatch color =
                                peaks
                                    |> List.filterMap
                                        (\cell ->
                                            case cell.state of
                                                Just ( color_, _ ) ->
                                                    if color == color_ then
                                                        Just cell.coords
                                                    else
                                                        Nothing

                                                Nothing ->
                                                    Nothing
                                        )
                                    |> List.head
                        in
                            case ( firstMatch color_a, firstMatch color_b, coords ) of
                                ( Just ( matchX, _ ), _, ( x, _ ) ) ->
                                    if matchX > x then
                                        Just Right
                                    else if matchX < x then
                                        Just Left
                                    else
                                        Just Down

                                ( _, Just ( matchX, _ ), ( x, _ ) ) ->
                                    if matchX > x then
                                        Just Right
                                    else if matchX < x then
                                        Just Left
                                    else
                                        Just Down

                                _ ->
                                    Just Left


withNext : ( Color, Color ) -> Model -> Model
withNext next model =
    { model | next = next }


withVirus : Color -> Grid.Coords -> Model -> Model
withVirus color coords model =
    { model
        | contents =
            Grid.setState ( color, Virus )
                coords
                model.contents
    }


withControls : (Int -> Maybe Direction) -> Model -> Model
withControls controls model =
    { model | controls = Keyboard controls }


withBombs : List Color -> Model -> Model
withBombs colors model =
    { model | bombs = model.bombs ++ colors }


type Msg
    = NewPill ( Color, Color )
    | KeyDown (Maybe Direction)
    | TickTock Posix
    | Bomb Color Int


type Direction
    = Up
    | Down
    | Left
    | Right


subscriptions : Speed -> Model -> Sub Msg
subscriptions speed model =
    Sub.batch
        [ Time.every (tickForSpeed speed) TickTock
        , case model.controls of
            Keyboard controls ->
                onKeyDown (Decode.map (controls >> KeyDown) keyCode)

            Bot controls ->
                let
                    direction =
                        controls model.contents model.mode
                in
                    Time.every (tickForSpeed speed / 2) (\_ -> KeyDown direction)
        ]


tickForSpeed : Speed -> Float
tickForSpeed speed =
    case speed of
        High ->
            300

        Med ->
            700

        Low ->
            1000



-- UPDATE


update : { onBomb : List Color -> Maybe msg } -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update { onBomb } msg model =
    case ( model.mode, msg ) of
        ( Falling cleared, NewPill next ) ->
            let
                ( a, b ) =
                    model.next
            in
                ( { model
                    | mode = PlacingPill (Horizontal a b) ( 4, 0 )
                    , next = next
                  }
                , Cmd.none
                , if (List.length cleared) > 1 then
                    onBomb cleared
                  else
                    Nothing
                )

        ( PlacingPill pill ( x, y ), KeyDown key ) ->
            let
                moveIfAvailable : Pill -> Grid.Coords -> ( Model, Cmd Msg, Maybe msg )
                moveIfAvailable pill_ coords =
                    withNothing
                        (if isAvailable coords pill_ model.contents then
                            { model | mode = PlacingPill pill_ coords }
                         else
                            model
                        )
            in
                case key of
                    Just Up ->
                        let
                            newPill =
                                case pill of
                                    Horizontal a b ->
                                        Vertical a b

                                    Vertical a b ->
                                        Horizontal b a
                        in
                            moveIfAvailable newPill ( x, y )

                    Just Left ->
                        moveIfAvailable pill ( x - 1, y )

                    Just Right ->
                        moveIfAvailable pill ( x + 1, y )

                    Just Down ->
                        moveIfAvailable pill ( x, y + 1 )

                    Nothing ->
                        withNothing model

        ( _, KeyDown _ ) ->
            withNothing model

        ( _, TickTock _ ) ->
            advance model

        ( Bombing, Bomb color x ) ->
            let
                contents =
                    Grid.setState
                        ( color, Pill Nothing )
                        ( x, 1 )
                        model.contents

                model_ =
                    { model | contents = contents }
            in
                case model.bombs of
                    head :: tail ->
                        ( { model_ | bombs = tail }
                        , Random.generate (Bomb head) <|
                            generateBomb model_.contents
                        , Nothing
                        )

                    _ ->
                        ( { model_ | mode = Falling [] }, Cmd.none, Nothing )

        _ ->
            withNothing model


withNothing : Model -> ( Model, Cmd Msg, Maybe msg )
withNothing model =
    ( model, Cmd.none, Nothing )


advance : Model -> ( Model, Cmd Msg, Maybe msg )
advance model =
    case model.mode of
        PlacingPill pill ( x, y ) ->
            let
                newCoords =
                    ( x, y + 1 )

                afterPill : Pill -> Grid.Coords -> Model
                afterPill pill_ coords =
                    let
                        newContents =
                            addPill pill_ coords model.contents

                        modify =
                            if canSweep newContents then
                                sweep
                            else
                                \m -> { m | contents = fall newContents }
                    in
                        modify
                            { model
                                | mode = Falling []
                                , contents = newContents
                            }
            in
                withNothing
                    (if isAvailable newCoords pill model.contents then
                        { model | mode = PlacingPill pill newCoords }
                     else
                        afterPill pill ( x, y )
                    )

        Falling _ ->
            let
                timeToFall : Bool
                timeToFall =
                    model.contents
                        |> Grid.filter
                            (\{ coords } -> canFall coords model.contents)
                        |> (List.isEmpty >> not)
            in
                if timeToFall then
                    withNothing { model | contents = fall model.contents }
                else if canSweep model.contents then
                    ( sweep model, Cmd.none, Nothing )
                else
                    case List.head model.bombs of
                        Just _ ->
                            advance { model | mode = Bombing }

                        Nothing ->
                            ( model
                            , Random.generate NewPill <|
                                generatePill
                            , Nothing
                            )

        Bombing ->
            case model.bombs of
                head :: tail ->
                    ( { model | bombs = tail }
                    , Random.generate (Bomb head) <|
                        generateBomb model.contents
                    , Nothing
                    )

                _ ->
                    ( model, Cmd.none, Nothing )


addPill : Pill -> Grid.Coords -> Bottle -> Bottle
addPill pill coords bottle =
    colorCoords pill coords
        |> List.foldl
            (\( coords_, color, dependent ) grid ->
                Grid.setState ( color, Pill (Just dependent) ) coords_ grid
            )
            bottle


colorCoords : Pill -> Grid.Coords -> List ( Grid.Coords, Color, Dependent )
colorCoords pill coords =
    let
        ( ( a_color, a_dep ), ( b_color, b_dep ) ) =
            case pill of
                Horizontal a b ->
                    ( ( a, Right ), ( b, Left ) )

                Vertical a b ->
                    ( ( a, Down ), ( b, Up ) )
    in
        case pillCoordsPair pill coords of
            first :: second :: [] ->
                [ ( first, a_color, a_dep ), ( second, b_color, b_dep ) ]

            _ ->
                []


fall : Bottle -> Bottle
fall bottle =
    Grid.map
        (\({ coords, state } as cell) ->
            let
                ( x, y ) =
                    coords
            in
                if canFall ( x, y ) bottle then
                    -- look above
                    if canFall ( x, y - 1 ) bottle then
                        { cell
                            | state =
                                .state <| Grid.findCellAtCoords ( x, y - 1 ) bottle
                        }
                    else
                        { cell | state = Nothing }
                else if state == Nothing && canFall ( x, y - 1 ) bottle then
                    { cell
                        | state =
                            .state <|
                                Grid.findCellAtCoords ( x, y - 1 ) bottle
                    }
                else
                    cell
        )
        bottle


sweep : Model -> Model
sweep ({ contents } as model) =
    let
        coordsLosingDependent =
            contents
                |> Grid.filter
                    (\({ coords, state } as cell) ->
                        case state of
                            Just ( _, Pill (Just dependent) ) ->
                                if isCleared coords contents then
                                    True
                                else
                                    False

                            _ ->
                                False
                    )
                |> List.map
                    (\{ coords, state } ->
                        case state of
                            Just ( _, Pill (Just dependent) ) ->
                                coordsWithDirection coords dependent

                            _ ->
                                -- Shouldn't have made it thru the preceding filter
                                ( -1, -1 )
                    )
                |> Set.fromList

        swept =
            Grid.map
                (\({ coords, state } as cell) ->
                    if isCleared coords contents then
                        { cell | state = Nothing }
                    else if Set.member coords coordsLosingDependent then
                        case state of
                            Just ( color, _ ) ->
                                { cell | state = Just ( color, Pill Nothing ) }

                            Nothing ->
                                cell
                    else
                        cell
                )
                contents

        diff : List (Cell Contents)
        diff =
            Grid.difference
                (\a b ->
                    case ( a, b ) of
                        ( Just _, Nothing ) ->
                            True

                        _ ->
                            False
                )
                contents
                swept

        clearedLines : List (Cell Contents) -> List Color
        clearedLines cells =
            case cells of
                [] ->
                    []

                x :: xs ->
                    case x.state of
                        Just ( color, _ ) ->
                            color
                                :: (xs
                                        |> List.filter
                                            (\c ->
                                                case ( x.coords, c.coords ) of
                                                    ( ( xx, xy ), ( cx, cy ) ) ->
                                                        cx /= xx && cy /= xy
                                            )
                                        |> clearedLines
                                   )

                        Nothing ->
                            []

        alreadyCleared =
            case model.mode of
                Falling cleared ->
                    cleared

                _ ->
                    -- should always be in Falling. can types enforce this?
                    []
    in
        { model | contents = swept, mode = Falling (alreadyCleared ++ (clearedLines diff)) }


coordsWithDirection : Grid.Coords -> Direction -> Grid.Coords
coordsWithDirection ( x, y ) direction =
    case direction of
        Up ->
            ( x, y - 1 )

        Down ->
            ( x, y + 1 )

        Left ->
            ( x - 1, y )

        Right ->
            ( x + 1, y )



-- QUERIES


pillCoordsPair : Pill -> Grid.Coords -> List Grid.Coords
pillCoordsPair pill ( x, y ) =
    case pill of
        Horizontal _ _ ->
            [ ( x, y + 1 ), ( x + 1, y + 1 ) ]

        Vertical _ _ ->
            [ ( x, y ), ( x, y + 1 ) ]


isAvailable : Grid.Coords -> Pill -> Bottle -> Bool
isAvailable (( x, y ) as coords) pill grid =
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
            pillCoordsPair pill coords
                |> List.map (\p -> Grid.isEmpty p grid)
                |> List.all identity
    in
        inBottle && noOccupant


canSweep : Bottle -> Bool
canSweep grid =
    grid
        |> Grid.filter
            (\cell ->
                isCleared cell.coords grid
            )
        |> (List.length >> (/=) 0)


canFall : Grid.Coords -> Bottle -> Bool
canFall coords bottle =
    let
        cell =
            Grid.findCellAtCoords coords bottle

        hasRoom : List (Cell Contents) -> Bool
        hasRoom cells =
            case cells of
                [] ->
                    False

                head :: tail ->
                    case head.state of
                        Nothing ->
                            True

                        Just ( _, Pill Nothing ) ->
                            hasRoom tail

                        Just ( _, Pill dependent ) ->
                            canFall head.coords bottle

                        Just ( _, Virus ) ->
                            False
    in
        case cell.state of
            Just ( _, Pill Nothing ) ->
                Grid.below coords bottle |> hasRoom

            Just ( _, Pill (Just Up) ) ->
                Grid.below coords bottle |> hasRoom

            Just ( _, Pill (Just Down) ) ->
                canFall (coordsWithDirection coords Down) bottle

            Just ( _, Pill (Just dependent) ) ->
                -- Left or Right
                (Grid.below coords bottle |> hasRoom)
                    && (bottle
                            |> Grid.below (coordsWithDirection coords dependent)
                            |> hasRoom
                       )

            _ ->
                False


isCleared : Grid.Coords -> Bottle -> Bool
isCleared ( x, y ) grid =
    let
        cell =
            Grid.findCellAtCoords ( x, y ) grid

        len =
            4

        horizontal : List (List (Cell Contents))
        horizontal =
            neighbors (\offset -> ( x + offset, y ))

        vertical : List (List (Cell Contents))
        vertical =
            neighbors (\offset -> ( x, y + offset ))

        neighbors f =
            List.range (len * -1 + 1) (len - 1)
                |> List.map f
                |> List.map (\coords -> Grid.findCellAtCoords coords grid)
                |> subLists len
    in
        case cell.state of
            Nothing ->
                False

            Just ( color, _ ) ->
                List.any
                    (List.all
                        (\cell_ ->
                            case cell_.state of
                                Just ( c, _ ) ->
                                    c == color

                                Nothing ->
                                    False
                        )
                    )
                    (vertical ++ horizontal)


totalViruses : Bottle -> Int
totalViruses contents =
    List.length <|
        Grid.filter
            (\c ->
                case c.state of
                    Just ( _, Virus ) ->
                        True

                    _ ->
                        False
            )
            contents


hasConflict : Model -> Bool
hasConflict { mode, contents } =
    case mode of
        PlacingPill pill coords ->
            pillCoordsPair pill coords
                |> List.map (\p -> Grid.isEmpty p contents)
                |> List.any not

        _ ->
            False



-- GENERATORS


generateEmptyCoords : Bottle -> Generator Grid.Coords
generateEmptyCoords grid =
    let
        emptyCoords : List ( Int, Int )
        emptyCoords =
            grid
                |> Grid.filter
                    (\{ coords } ->
                        Tuple.second coords >= 5 && Grid.isEmpty coords grid
                    )
                |> List.map .coords
    in
        selectWithDefault ( -1, -1 ) emptyCoords


generatePill : Generator ( Color, Color )
generatePill =
    Random.pair generateColor generateColor


generateColor : Generator Color
generateColor =
    selectWithDefault Blue [ Red, Yellow, Blue ]


generateBomb : Bottle -> Generator Int
generateBomb bottle =
    selectWithDefault -1
        (Grid.topRow bottle
            |> List.filter
                (\c ->
                    case c.state of
                        Just _ ->
                            False

                        Nothing ->
                            True
                )
            |> List.map (.coords >> Tuple.first)
        )



-- VIEW


view : Model -> Html msg
view { contents, mode } =
    div []
        [ div
            [ style "display" "inline-block"
            , style "border" "3px solid #CCC"
            , style "border-radius" "3px"
            , style "background" "#000"
            ]
            (List.map
                (\column ->
                    div
                        [ style "display" "inline-block", style "vertical-align" "top" ]
                        (List.map
                            (\cell ->
                                case cell.state of
                                    Nothing ->
                                        div cellStyle []

                                    Just ( color, Pill dependent ) ->
                                        viewPill dependent color

                                    Just ( color, Virus ) ->
                                        viewVirus color
                            )
                            column
                        )
                )
                (case mode of
                    PlacingPill pill coords ->
                        addPill pill coords contents

                    _ ->
                        contents
                )
            )
        ]


viewPill : Maybe Dependent -> Color -> Html msg
viewPill dependent color =
    viewColor color
        8
        (case dependent of
            Just Up ->
                [ (style "border-top-left-radius" (px 0)), (style "border-top-right-radius" (px 0)) ]

            Just Down ->
                [ (style "border-bottom-left-radius" (px 0)), (style "border-bottom-right-radius" (px 0)) ]

            Just Left ->
                [ (style "border-top-left-radius" (px 0)), (style "border-bottom-left-radius" (px 0)) ]

            Just Right ->
                [ (style "border-top-right-radius" (px 0)), (style "border-bottom-right-radius" (px 0)) ]

            Nothing ->
                []
        )
        []


viewVirus : Color -> Html msg
viewVirus color =
    viewColor color 3 [] [ text "◔̯◔" ]


viewColor : Color -> Int -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
viewColor color radius extraStyle =
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
            ([ style "background-color" bg
             , style "border-top-left-radius" (px radius)
             , style "border-top-right-radius" (px radius)
             , style "border-bottom-left-radius" (px radius)
             , style "border-bottom-right-radius" (px radius)
             ]
                ++ cellStyle
                ++ extraStyle
            )


cellStyle : List (Html.Attribute msg)
cellStyle =
    [ style "width" (px cellSize)
    , style "height" (px cellSize)
    , style "border" "1px solid black"
    ]


cellSize : Int
cellSize =
    24



-- UTILS


subLists : Int -> List a -> List (List a)
subLists len list =
    if List.length list < len then
        []
    else
        List.take len list :: subLists len (List.drop 1 list)
