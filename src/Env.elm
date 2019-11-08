module Env exposing
    ( Mode(..)
    , Model
    , Msg(..)
    , hasConflict
    , init
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

import Bottle exposing (Bottle, CellType(..))
import Browser.Events exposing (onKeyDown)
import Direction exposing (Direction(..))
import Element exposing (none, px)
import Grid exposing (Cell)
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (keyCode)
import Json.Decode as Decode
import Pill exposing (Color(..), Orientation(..), Pill)
import Random exposing (Generator(..))
import Set
import Speed exposing (Speed(..))
import Time exposing (Posix)


type Controls
    = Keyboard (Int -> Maybe Direction)
    | Bot BotInterface


type alias BotInterface =
    Model -> ( Maybe Direction, Maybe Pill )


type Mode
    = PlacingPill Pill
    | Falling (List Color)
    | Bombing


type alias Model =
    { bottle : Bottle
    , mode : Mode
    , next : ( Color, Color )
    , controls : Controls
    , bombs : List Color
    , goal : Maybe Pill
    }


init : Model
init =
    { bottle = Grid.fromDimensions 8 16
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
        | bottle =
            Grid.setState ( color, Virus )
                coords
                model.bottle
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
    = NewPill ( Color, Color ) -- TODO: Pill?
    | KeyDown (Maybe Direction)
    | TickTock Posix
    | Bomb Color Int
    | SetGoal ( Maybe Direction, Maybe Pill )


subscriptions : Speed -> Model -> Sub Msg
subscriptions speed model =
    Sub.batch
        [ Time.every (Speed.tick speed) TickTock
        , case model.controls of
            Keyboard controls ->
                onKeyDown (Decode.map (controls >> KeyDown) keyCode)

            Bot bot ->
                Time.every (Speed.tick speed / 4) (\_ -> SetGoal (bot model))
        ]



-- UPDATE


update : { onBomb : List Color -> Maybe msg } -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update props msg model =
    case ( model.mode, msg ) of
        ( Falling cleared, NewPill next ) ->
            ( { model
                | mode = PlacingPill (Pill.fromColors model.next)
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
                        (if Bottle.isAvailable pill_ model.bottle then
                            { model | mode = PlacingPill pill_ }

                         else
                            model
                        )
            in
            case key of
                Just Up ->
                    moveIfAvailable (Pill.turnRight pill)

                Just direction ->
                    moveIfAvailable
                        (Pill.mapCoords (Bottle.coordsWithDirection direction) pill)

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
                bottle =
                    Grid.setState
                        ( color, Bottle.Pill Nothing )
                        ( x, 1 )
                        model.bottle

                model_ =
                    { model | bottle = bottle }
            in
            case model.bombs of
                head :: tail ->
                    ( { model_ | bombs = tail }
                    , Random.generate (Bomb head) <|
                        Bottle.generateBomb model_.bottle
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
        PlacingPill pill ->
            let
                newPill =
                    Pill.mapCoords (Bottle.coordsWithDirection Down) pill

                afterPill : Pill -> Model
                afterPill pill_ =
                    let
                        newBottle =
                            Bottle.addPill pill_ model.bottle

                        modify =
                            if Bottle.canSweep newBottle then
                                sweep

                            else
                                \m -> { m | bottle = Bottle.fall newBottle }
                    in
                    modify
                        { model
                            | mode = Falling []
                            , bottle = newBottle
                        }
            in
            withNothing
                (if Bottle.isAvailable newPill model.bottle then
                    { model | mode = PlacingPill newPill }

                 else
                    afterPill pill
                )

        Falling _ ->
            let
                timeToFall : Bool
                timeToFall =
                    Grid.any
                        (\{ coords } -> Bottle.canFall coords model.bottle)
                        model.bottle
            in
            if timeToFall then
                withNothing { model | bottle = Bottle.fall model.bottle }

            else if Bottle.canSweep model.bottle then
                ( sweep model, Cmd.none, Nothing )

            else if List.length model.bombs == 0 then
                ( model
                , Random.generate NewPill <|
                    Bottle.generatePill
                , Nothing
                )

            else
                advance { model | mode = Bombing }

        Bombing ->
            case model.bombs of
                head :: tail ->
                    ( { model | bombs = tail }
                    , Random.generate (Bomb head) <|
                        Bottle.generateBomb model.bottle
                    , Nothing
                    )

                _ ->
                    ( model, Cmd.none, Nothing )


sweep : Model -> Model
sweep ({ bottle } as model) =
    let
        coordsLosingDependent =
            bottle
                |> Grid.filterMap
                    (\{ coords, state } ->
                        case state of
                            Just ( _, Bottle.Pill (Just dependent) ) ->
                                if Bottle.isCleared coords bottle then
                                    Just <|
                                        Bottle.coordsWithDirection dependent coords

                                else
                                    Nothing

                            _ ->
                                Nothing
                    )
                |> Set.fromList

        swept =
            Grid.map
                (\({ coords, state } as cell) ->
                    if Bottle.isCleared coords bottle then
                        { cell | state = Nothing }

                    else if Set.member coords coordsLosingDependent then
                        case state of
                            Just ( color, _ ) ->
                                { cell | state = Just ( color, Bottle.Pill Nothing ) }

                            Nothing ->
                                cell

                    else
                        cell
                )
                bottle

        diff : List (Cell Bottle.Contents)
        diff =
            Grid.difference
                (\a b ->
                    case ( a, b ) of
                        ( Just _, Nothing ) ->
                            True

                        _ ->
                            False
                )
                bottle
                swept

        clearedLines : List (Cell Bottle.Contents) -> List Color
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
    { model | bottle = swept, mode = Falling (alreadyCleared ++ clearedLines diff) }



-- QUERIES


hasConflict : Model -> Bool
hasConflict { mode, bottle } =
    case mode of
        PlacingPill pill ->
            Pill.coordsPair pill
                |> List.map (\coords -> Grid.isEmpty coords bottle)
                |> List.any not

        _ ->
            False


totalViruses : Model -> Int
totalViruses { bottle } =
    Bottle.totalViruses bottle



-- VIEW


view : Model -> Html msg
view { bottle, mode } =
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

                                    Just ( color, Bottle.Pill dependent ) ->
                                        viewPillCell dependent color

                                    Just ( color, Virus ) ->
                                        viewVirus color
                            )
                            column
                        )
                )
                (case mode of
                    PlacingPill pill ->
                        Bottle.addPill pill bottle

                    _ ->
                        bottle
                )
            )
        ]


viewPillCell : Maybe Direction -> Color -> Html msg
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
