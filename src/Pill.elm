module Pill exposing
    ( Color(..)
    , Orientation(..)
    , Pill
    , coordsPair
    , mapCoords
    , mapOrientation
    , turnRight
    )

import Grid


type alias Pill =
    { orientation : Orientation
    , coords : Grid.Coords
    }


type Orientation
    = Horizontal ( Color, Color )
    | Vertical ( Color, Color )


type Color
    = Red
    | Blue
    | Yellow


mapCoords : (Grid.Coords -> Grid.Coords) -> Pill -> Pill
mapCoords map { orientation, coords } =
    { orientation = orientation, coords = map coords }


mapOrientation : (Orientation -> Orientation) -> Pill -> Pill
mapOrientation map { orientation, coords } =
    { orientation = map orientation, coords = coords }


turnRight : Pill -> Pill
turnRight pill =
    mapOrientation
        (\o ->
            case o of
                Horizontal pair ->
                    Vertical pair

                Vertical ( a, b ) ->
                    Horizontal ( b, a )
        )
        pill


coordsPair : Pill -> List Grid.Coords
coordsPair pill =
    let
        ( x, y ) =
            pill.coords
    in
    case pill.orientation of
        Horizontal _ ->
            [ ( x, y + 1 ), ( x + 1, y + 1 ) ]

        Vertical _ ->
            [ ( x, y ), ( x, y + 1 ) ]
