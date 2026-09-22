module Pill exposing
    ( Color(..)
    , Orientation(..)
    , Pill
    , coordsPair
    , fromColors
    , mapCoords
    , mapOrientation
    , turnRight
    )

import Grid exposing (Coords)


{-| `coords` identifies the bottom-left occupied cell in either orientation.
-}
type alias Pill =
    { orientation : Orientation
    , coords : Coords
    }


fromColors : ( Color, Color ) -> Pill
fromColors colors =
    { orientation = Horizontal colors
    , coords = ( 4, 1 )
    }


type Orientation
    = Horizontal ( Color, Color )
    | Vertical ( Color, Color )


type Color
    = Red
    | Blue
    | Yellow


mapCoords : (Coords -> Coords) -> Pill -> Pill
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


coordsPair : Pill -> List Coords
coordsPair pill =
    let
        ( x, y ) =
            pill.coords
    in
    case pill.orientation of
        Horizontal _ ->
            [ ( x, y ), ( x + 1, y ) ]

        Vertical _ ->
            [ ( x, y - 1 ), ( x, y ) ]
