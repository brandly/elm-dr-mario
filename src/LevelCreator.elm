module LevelCreator exposing (..)

import Grid exposing (Cell, Column, Grid)
import Random exposing (Generator(..))
import RandomExtra exposing (selectWithDefault)
import Bottle exposing (Bottle, Color(..))


type alias Model =
    { level : Int
    , bottle : Bottle.Model
    }


type Msg
    = NewVirus ( Color, Grid.Coords )
    | NewPill ( Color, Color )


init : Int -> ( Model, Cmd Msg )
init level =
    let
        bottle =
            Bottle.init
    in
        ( { level = level
          , bottle = bottle
          }
        , randomNewVirus bottle.contents
        )


virusesForLevel : Int -> Int
virusesForLevel level =
    min 84 (4 * level + 4)


update : { onCreated : Model -> msg } -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update { onCreated } action ({ level, bottle } as model) =
    case action of
        NewVirus ( color, coords ) ->
            let
                newBottle =
                    Bottle.withVirus color coords bottle
            in
                if Bottle.isCleared coords newBottle.contents then
                    -- would create a 4-in-a-row, so let's try a new virus
                    ( model, randomNewVirus bottle.contents, Nothing )
                else if Bottle.totalViruses newBottle.contents >= virusesForLevel level then
                    ( { model | bottle = newBottle }
                    , Random.generate NewPill <|
                        Bottle.generatePill
                    , Nothing
                    )
                else
                    ( { model | bottle = newBottle }
                    , randomNewVirus newBottle.contents
                    , Nothing
                    )

        NewPill colors ->
            let
                model_ =
                    { level = level
                    , bottle =
                        bottle |> Bottle.withNext colors
                    }
            in
                ( model_
                , Cmd.none
                , Just (onCreated model_)
                )


randomNewVirus : Bottle -> Cmd Msg
randomNewVirus bottle =
    Random.generate NewVirus <|
        Random.pair Bottle.generateColor (Bottle.generateEmptyCoords bottle)
