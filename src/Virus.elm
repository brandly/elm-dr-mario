module Virus exposing (..)

import Random exposing (Generator)
import RandomExtra


type Color
    = Red
    | Blue
    | Yellow


generateColor : Generator Color
generateColor =
    RandomExtra.selectWithDefault Blue [ Red, Yellow, Blue ]
