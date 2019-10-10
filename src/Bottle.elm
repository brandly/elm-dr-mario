module Bottle exposing
    ( Bottle
    , Color(..)
    , Contents
    , Direction(..)
    , Mode(..)
    , Model
    , Msg(..)
    , Orientation(..)
    , Pill
    , generateEmptyCoords
    , generatePill
    , getColor
    , hasConflict
    , init
    , isCleared
    , subscriptions
    , totalViruses
    , update
    , view
    , viewPill
    , withBombs
    , withBot
    , withControls
    , withNext
    , withVirus
    )

import Browser.Events exposing (onKeyDown)
import Element exposing (none, px)
import Grid exposing (Cell, Grid)
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (keyCode)
import Json.Decode as Decode
import Random exposing (Generator(..))
import RandomExtra exposing (selectWithDefault)
import Set
import Speed exposing (Speed(..))
import Time exposing (Posix)



-- split Bottle (just a data structure?) from like Environment
-- bot goes Env -> Decision
-- things get more readable?
-- should only be a `goal` when Bot is in control


type Controls
    = Keyboard (Int -> Maybe Direction)
    | Bot BotInterface


type alias BotInterface =
    Bottle -> Mode -> ( Maybe Direction, Maybe ( Int, Orientation ) )


type Mode
    = PlacingPill Pill
    | Falling (List Color)
    | Bombing


type alias Pill =
    { orientation : Orientation
    , coords : Grid.Coords
    }


type Orientation
    = Horizontal ( Color, Color )
    | Vertical ( Color, Color )


type Type
    = Virus
      -- TODO: rename to `Pill` once files are broken up?
    | PillType (Maybe Dependent)


type alias Dependent =
    Direction


type Color
    = Red
    | Blue
    | Yellow


getColor : Int -> Color
getColor index =
    case remainderBy 3 index of
        0 ->
            Red

        1 ->
            Blue

        _ ->
            Yellow


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
    , goal : Maybe ( Int, Orientation )
    }


init : Model
init =
    { contents = Grid.fromDimensions 8 16
    , mode = Falling []
    , next = ( Red, Red )
    , controls = Keyboard (\_ -> Nothing)
    , bombs = []
    , goal = Nothing
    }


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


withBot : BotInterface -> Model -> Model
withBot bot model =
    { model | controls = Bot bot }


withBombs : List Color -> Model -> Model
withBombs colors model =
    { model | bombs = model.bombs ++ colors }


type Msg
    = NewPill ( Color, Color )
    | KeyDown (Maybe Direction)
    | TickTock Posix
    | Bomb Color Int
    | SetGoal ( Maybe Direction, Maybe ( Int, Orientation ) )


type Direction
    = Up
    | Down
    | Left
    | Right


subscriptions : Speed -> Model -> Sub Msg
subscriptions speed model =
    Sub.batch
        [ Time.every (Speed.tick speed) TickTock
        , case model.controls of
            Keyboard controls ->
                onKeyDown (Decode.map (controls >> KeyDown) keyCode)

            Bot bot ->
                let
                    direction =
                        bot model.contents model.mode
                in
                Time.every (Speed.tick speed / 4) (\_ -> SetGoal direction)
        ]



-- UPDATE


update : { onBomb : List Color -> Maybe msg } -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update props msg model =
    case ( model.mode, msg ) of
        ( Falling cleared, NewPill next ) ->
            ( { model
                | mode =
                    PlacingPill
                        { orientation = Horizontal model.next
                        , coords = ( 4, 0 )
                        }
                , next = next
              }
            , Cmd.none
            , if List.length cleared > 1 then
                props.onBomb cleared

              else
                Nothing
            )

        ( PlacingPill pill, KeyDown key ) ->
            let
                moveIfAvailable : Pill -> ( Model, Cmd Msg, Maybe msg )
                moveIfAvailable pill_ =
                    withNothing
                        (if isAvailable pill_ model.contents then
                            { model | mode = PlacingPill pill_ }

                         else
                            model
                        )
            in
            case key of
                Just Up ->
                    moveIfAvailable
                        (mapOrientation
                            (\o ->
                                -- TODO: Pill.flip?
                                case o of
                                    Horizontal pair ->
                                        Vertical pair

                                    Vertical ( a, b ) ->
                                        Horizontal ( b, a )
                            )
                            pill
                        )

                Just direction ->
                    moveIfAvailable
                        (mapCoords (coordsWithDirection direction) pill)

                Nothing ->
                    withNothing model

        ( _, KeyDown _ ) ->
            withNothing model

        ( _, SetGoal ( key, goal ) ) ->
            update props (KeyDown key) { model | goal = goal }

        ( _, TickTock _ ) ->
            advance model

        ( Bombing, Bomb color x ) ->
            let
                contents =
                    Grid.setState
                        ( color, PillType Nothing )
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


mapCoords : (Grid.Coords -> Grid.Coords) -> Pill -> Pill
mapCoords map { orientation, coords } =
    { orientation = orientation, coords = map coords }


mapOrientation : (Orientation -> Orientation) -> Pill -> Pill
mapOrientation map { orientation, coords } =
    { orientation = map orientation, coords = coords }


withNothing : Model -> ( Model, Cmd Msg, Maybe msg )
withNothing model =
    ( model, Cmd.none, Nothing )


advance : Model -> ( Model, Cmd Msg, Maybe msg )
advance model =
    case model.mode of
        PlacingPill pill ->
            let
                newPill =
                    mapCoords (coordsWithDirection Down) pill

                afterPill : Pill -> Model
                afterPill pill_ =
                    let
                        newContents =
                            addPill pill_ model.contents

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
                (if isAvailable newPill model.contents then
                    { model | mode = PlacingPill newPill }

                 else
                    afterPill pill
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


addPill : Pill -> Bottle -> Bottle
addPill pill bottle =
    colorCoords pill
        |> List.foldl
            (\( coords_, color, dependent ) grid ->
                Grid.setState ( color, PillType (Just dependent) ) coords_ grid
            )
            bottle


colorCoords : Pill -> List ( Grid.Coords, Color, Dependent )
colorCoords pill =
    let
        ( ( a_color, a_dep ), ( b_color, b_dep ) ) =
            case pill.orientation of
                Horizontal ( a, b ) ->
                    ( ( a, Right ), ( b, Left ) )

                Vertical ( a, b ) ->
                    ( ( a, Down ), ( b, Up ) )
    in
    case pillCoordsPair pill of
        first :: second :: [] ->
            [ ( first, a_color, a_dep ), ( second, b_color, b_dep ) ]

        _ ->
            []


fall : Bottle -> Bottle
fall bottle =
    Grid.map
        (\({ coords, state } as cell) ->
            let
                above =
                    coordsWithDirection Up coords
            in
            if canFall coords bottle then
                -- look above
                if canFall above bottle then
                    { cell | state = .state <| Grid.findCellAtCoords above bottle }

                else
                    { cell | state = Nothing }

            else if state == Nothing && canFall above bottle then
                { cell | state = .state <| Grid.findCellAtCoords above bottle }

            else
                cell
        )
        bottle


sweep : Model -> Model
sweep ({ contents } as model) =
    let
        coordsLosingDependent =
            contents
                |> Grid.filterMap
                    (\{ coords, state } ->
                        case state of
                            Just ( _, PillType (Just dependent) ) ->
                                if isCleared coords contents then
                                    Just <|
                                        coordsWithDirection dependent coords

                                else
                                    Nothing

                            _ ->
                                Nothing
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
                                { cell | state = Just ( color, PillType Nothing ) }

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
    { model | contents = swept, mode = Falling (alreadyCleared ++ clearedLines diff) }



-- TODO: reverse arg order


coordsWithDirection : Direction -> Grid.Coords -> Grid.Coords
coordsWithDirection direction ( x, y ) =
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


pillCoordsPair : Pill -> List Grid.Coords
pillCoordsPair pill =
    let
        ( x, y ) =
            pill.coords
    in
    case pill.orientation of
        Horizontal _ ->
            [ ( x, y + 1 ), ( x + 1, y + 1 ) ]

        Vertical _ ->
            [ ( x, y ), ( x, y + 1 ) ]


isAvailable : Pill -> Bottle -> Bool
isAvailable pill grid =
    let
        ( x, y ) =
            pill.coords

        aboveBottom =
            y < Grid.height grid

        withinRight =
            case pill.orientation of
                Vertical _ ->
                    x <= Grid.width grid

                Horizontal _ ->
                    x < Grid.width grid

        inBottle =
            (x >= 1)
                && withinRight
                && aboveBottom

        noOccupant =
            pillCoordsPair pill
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

                        Just ( _, PillType Nothing ) ->
                            hasRoom tail

                        Just ( _, PillType _ ) ->
                            canFall head.coords bottle

                        Just ( _, Virus ) ->
                            False
    in
    case cell.state of
        Just ( _, PillType Nothing ) ->
            Grid.below coords bottle |> hasRoom

        Just ( _, PillType (Just Up) ) ->
            Grid.below coords bottle |> hasRoom

        Just ( _, PillType (Just Down) ) ->
            canFall (coordsWithDirection Down coords) bottle

        Just ( _, PillType (Just dependent) ) ->
            -- Left or Right
            (Grid.below coords bottle |> hasRoom)
                && (bottle
                        |> Grid.below (coordsWithDirection dependent coords)
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
        PlacingPill pill ->
            pillCoordsPair pill
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
view { contents, mode, goal } =
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

                                    Just ( color, PillType dependent ) ->
                                        viewPillCell dependent color

                                    Just ( color, Virus ) ->
                                        viewVirus color
                            )
                            column
                        )
                )
                (case mode of
                    PlacingPill pill ->
                        addPill pill contents

                    _ ->
                        contents
                )
            )
        ]


viewPillCell : Maybe Dependent -> Color -> Html msg
viewPillCell dependent color =
    viewColor color
        8
        (case dependent of
            Just Up ->
                [ style "border-top-left-radius" (px 0), style "border-top-right-radius" (px 0) ]

            Just Down ->
                [ style "border-bottom-left-radius" (px 0), style "border-bottom-right-radius" (px 0) ]

            Just Left ->
                [ style "border-top-left-radius" (px 0), style "border-bottom-left-radius" (px 0) ]

            Just Right ->
                [ style "border-top-right-radius" (px 0), style "border-bottom-right-radius" (px 0) ]

            Nothing ->
                []
        )
        []


viewPill : ( Color, Color ) -> List (Html msg)
viewPill ( left, right ) =
    [ viewPillCell (Just Right) left
    , viewPillCell (Just Left) right
    ]


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
