module EnvCreator exposing
    ( Model
    , Msg(..)
    , init
    , update
    )

import Bottle exposing (Bottle)
import Env
import Grid
import Pill exposing (Color(..))
import Random exposing (Generator(..))


type alias Model =
    { level : Int
    , env : Env.Model
    }


type Msg
    = NewVirus Grid.Coords
    | NewPill ( Color, Color )


init : Int -> ( Model, Cmd Msg )
init level =
    let
        env =
            Env.init
    in
    ( { level = level
      , env = env
      }
    , randomNewVirus env.bottle
    )


virusesForLevel : Int -> Int
virusesForLevel level =
    min 84 (4 * level + 4)


update : { onCreated : Model -> msg } -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update { onCreated } action ({ level, env } as model) =
    case action of
        NewVirus coords ->
            let
                newEnv =
                    Env.withVirus color coords env

                color =
                    Bottle.getColor (Bottle.totalViruses env.bottle)
            in
            if Bottle.isCleared coords newEnv.bottle then
                -- would create a 4-in-a-row, so let's try a new virus
                ( model, randomNewVirus env.bottle, Nothing )

            else if Bottle.totalViruses newEnv.bottle >= virusesForLevel level then
                ( { model | env = newEnv }
                , Random.generate NewPill <|
                    Bottle.generatePill
                , Nothing
                )

            else
                ( { model | env = newEnv }
                , randomNewVirus newEnv.bottle
                , Nothing
                )

        NewPill colors ->
            let
                model_ =
                    { level = level
                    , env =
                        env |> Env.withNext colors
                    }
            in
            ( model_
            , Cmd.none
            , Just (onCreated model_)
            )


randomNewVirus : Bottle -> Cmd Msg
randomNewVirus env =
    Random.generate NewVirus <|
        Bottle.generateEmptyCoords env
