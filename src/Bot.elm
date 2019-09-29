module Bot exposing (trashBot)

import Array
import Bottle
    exposing
        ( Bottle
        , Color(..)
        , Contents
        , Direction(..)
        , Mode(..)
        , Pill(..)
        )
import Grid exposing (Cell, Coords)
import List.Extra


type alias Decision =
    ( Maybe Direction, Maybe ( Int, Pill ) )


trashBot : Bottle -> Mode -> Decision
trashBot bottle mode =
    case mode of
        Falling _ ->
            ( Nothing, Nothing )

        Bombing ->
            ( Nothing, Nothing )

        PlacingPill pill coords ->
            placingPill bottle pill coords


placingPill : Bottle -> Pill -> Coords -> Decision
placingPill bottle pill coords =
    let
        ( color_a, color_b ) =
            case pill of
                Vertical a b ->
                    ( a, b )

                Horizontal a b ->
                    ( a, b )

        options : List ( Int, Pill )
        options =
            let
                heads : List (Cell Contents)
                heads =
                    bottle
                        |> List.map (\column -> List.drop (Tuple.second coords - 1) column)
                        |> List.map
                            (\column ->
                                List.head column
                                    |> Maybe.withDefault
                                        { state = Nothing, coords = ( -1, -1 ) }
                            )

                getOpenings : List (Cell Contents) -> List (Cell Contents)
                getOpenings =
                    List.Extra.takeWhile (\cell -> cell.state == Nothing)

                ( before, after ) =
                    ( getOpenings (List.reverse (List.take (Tuple.first coords) heads))
                    , getOpenings (List.drop (Tuple.first coords) heads)
                    )

                openCells : List (Cell Contents)
                openCells =
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
                        ( x, Vertical color_a color_b )
                    )
            )
                ++ (if color_a == color_b then
                        []

                    else
                        List.range minX (maxX - 1)
                            |> List.map (\x -> ( x, Horizontal color_b color_a ))
                   )
                ++ (List.range minX (maxX - 1)
                        |> List.map (\x -> ( x, Horizontal color_a color_b ))
                   )

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
                                            Tuple.second cell.coords >= Tuple.second coords

                                        Nothing ->
                                            False
                                )
                            |> List.head
                    )
                |> List.filterMap identity

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

        orientationBonus : Pill -> Int
        orientationBonus o =
            if o == pill then
                2

            else
                case pill of
                    Horizontal _ _ ->
                        0

                    Vertical a b ->
                        if a == b then
                            1

                        else
                            0

        scores : List Int
        scores =
            List.map
                (\( x, orientation ) ->
                    orientationBonus orientation
                        + (case orientation of
                            Horizontal a b ->
                                colorIndexScore a x + colorIndexScore b (x + 1)

                            Vertical a b ->
                                if a == b then
                                    colorIndexScore a x + colorIndexScore b x

                                else
                                    colorIndexScore b x
                          )
                )
                options

        choice : Maybe ( Int, Pill )
        choice =
            Grid.zip scores options
                |> List.sortBy (Tuple.first >> (\a -> -a))
                |> List.map Tuple.second
                |> List.head

        withGoal : Maybe Direction -> ( Maybe Direction, Maybe ( Int, Pill ) )
        withGoal dir =
            ( dir, choice )
    in
    case ( choice, coords ) of
        ( Just ( aimX, pill_ ), ( x, _ ) ) ->
            if pill_ /= pill then
                withGoal <| Just Up

            else if aimX > x then
                withGoal <| Just Right

            else if aimX < x then
                withGoal <| Just Left

            else
                withGoal <| Just Down

        ( Nothing, _ ) ->
            withGoal <| Nothing
