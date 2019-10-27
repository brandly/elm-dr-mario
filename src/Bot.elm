module Bot exposing (trashBot)

import Array
import Bottle exposing (Bottle, Contents)
import Direction exposing (Direction(..))
import Env exposing (Mode(..))
import Grid exposing (Cell)
import List.Extra
import Pill exposing (Color(..), Orientation(..), Pill)


type alias Decision =
    ( Maybe Direction, Maybe Pill )


trashBot : Env.Model -> Decision
trashBot { bottle, mode } =
    case mode of
        Falling _ ->
            ( Nothing, Nothing )

        Bombing ->
            ( Nothing, Nothing )

        PlacingPill pill ->
            placingPill bottle pill


placingPill : Bottle -> Pill -> Decision
placingPill bottle { orientation, coords } =
    let
        ( color_a, color_b ) =
            case orientation of
                Vertical pair ->
                    pair

                Horizontal pair ->
                    pair

        options : List ( Int, Orientation )
        options =
            let
                heads : List (Cell Contents)
                heads =
                    bottle
                        |> List.map
                            -- drop everything above the pill
                            (\column -> List.drop (Tuple.second coords - 1) column)
                        |> List.filterMap List.head

                openCells : List (Cell Contents)
                openCells =
                    let
                        -- look outward from the pill
                        ( before, after ) =
                            ( takeWhileEmpty (List.reverse (List.take (Tuple.first coords) heads))
                            , takeWhileEmpty (List.drop (Tuple.first coords) heads)
                            )
                    in
                    before ++ after

                ( minX, maxX ) =
                    ( openCells
                        |> List.Extra.minimumBy (\cell -> Tuple.first cell.coords)
                        |> Maybe.map (.coords >> Tuple.first)
                        |> Maybe.withDefault (Tuple.first coords)
                    , openCells
                        |> List.Extra.maximumBy (\cell -> Tuple.first cell.coords)
                        |> Maybe.map (.coords >> Tuple.first)
                        |> Maybe.withDefault (Tuple.first coords)
                    )
            in
            (List.range minX maxX
                |> List.map
                    (\x ->
                        ( x, Vertical ( color_a, color_b ) )
                    )
            )
                ++ (if color_a == color_b then
                        []

                    else
                        List.range minX (maxX - 1)
                            |> List.map (\x -> ( x, Horizontal ( color_b, color_a ) ))
                   )
                ++ (List.range minX (maxX - 1)
                        |> List.map (\x -> ( x, Horizontal ( color_a, color_b ) ))
                   )

        peaks : List (Grid.Cell Contents)
        peaks =
            bottle
                |> List.filterMap
                    (\column ->
                        column
                            |> List.filter
                                (\cell ->
                                    case cell.state of
                                        Just _ ->
                                            Tuple.second cell.coords >= Tuple.second coords

                                        Nothing ->
                                            False
                                )
                            |> List.head
                    )

        colorIndexScore : Color -> Int -> Int
        colorIndexScore color index =
            let
                scoring =
                    { match = 120
                    , hole = 50
                    , conflict = 0
                    }

                colorAtIndex : Maybe Color
                colorAtIndex =
                    Array.fromList peaks
                        |> Array.get (index - 1)
                        |> Maybe.andThen (\cell -> cell.state)
                        |> Maybe.map (\state -> Tuple.first state)
            in
            case colorAtIndex of
                Nothing ->
                    scoring.hole

                Just aColor ->
                    if aColor == color then
                        scoring.match

                    else
                        scoring.conflict

        orientationBonus : Orientation -> Int
        orientationBonus o =
            if o == orientation then
                2

            else
                case orientation of
                    Horizontal _ ->
                        0

                    Vertical ( a, b ) ->
                        if a == b then
                            1

                        else
                            0

        scores : List Int
        scores =
            List.map
                (\( x, orientation_ ) ->
                    orientationBonus orientation_
                        + (case orientation_ of
                            Horizontal ( a, b ) ->
                                colorIndexScore a x + colorIndexScore b (x + 1)

                            Vertical ( a, b ) ->
                                if a == b then
                                    colorIndexScore a x + colorIndexScore b x

                                else
                                    colorIndexScore b x
                          )
                )
                options

        choice : Maybe ( Int, Orientation )
        choice =
            Grid.zip scores options
                |> List.sortBy (Tuple.first >> (\a -> -a))
                |> List.map Tuple.second
                |> List.head

        withGoal : Maybe Direction -> ( Maybe Direction, Maybe Pill )
        withGoal dir =
            ( dir
            , Maybe.map
                (\( x, orientation_ ) ->
                    { coords = ( x, 0 )
                    , orientation = orientation_
                    }
                )
                choice
            )
    in
    case ( choice, coords ) of
        ( Just ( aimX, pill_ ), ( x, _ ) ) ->
            if pill_ /= orientation then
                withGoal <| Just Up

            else if aimX > x then
                withGoal <| Just Right

            else if aimX < x then
                withGoal <| Just Left

            else
                withGoal <| Just Down

        ( Nothing, _ ) ->
            withGoal <| Nothing


takeWhileEmpty : List (Cell Contents) -> List (Cell Contents)
takeWhileEmpty =
    List.Extra.takeWhile (\cell -> cell.state == Nothing)
