module MatchupCreator exposing
    ( Matchup
    , Model(..)
    , Msg(..)
    , Opponent(..)
    , Player
    , Position(..)
    , init
    , mapEnv
    , mapPlayer
    , update
    )

import Bot
import Controls
import Env
import EnvCreator
import Speed exposing (Speed(..))


type alias Player =
    { env : Env.Model
    , level : Int
    , speed : Speed
    }


mapEnv : (Env.Model -> Env.Model) -> Player -> Player
mapEnv map player =
    { player | env = map player.env }


type Opponent
    = Human
    | Bot


type alias Matchup =
    { first : Player
    , second : Player
    }


type Position
    = First
    | Second


mapPlayer : Position -> (Player -> Player) -> Matchup -> Matchup
mapPlayer position map state =
    case position of
        First ->
            { state | first = map state.first }

        Second ->
            { state | second = map state.second }


type Model
    = PrepareFirst Opponent Matchup EnvCreator.Model
    | PrepareSecond Opponent Matchup EnvCreator.Model
    | Created Matchup


type Msg
    = CreatorMsg EnvCreator.Msg
    | Ready Matchup


type alias Options =
    { level : Int
    , speed : Speed
    }


init : Opponent -> Options -> Options -> ( Model, Cmd Msg )
init opponent first second =
    let
        ( creator, cmd ) =
            EnvCreator.init first.level

        withOpts : Options -> Player
        withOpts opts =
            { level = opts.level
            , speed = opts.speed
            , env = Env.init
            }
    in
    ( PrepareFirst
        opponent
        { first = withOpts first
        , second = withOpts second
        }
        creator
    , Cmd.map CreatorMsg cmd
    )



-- UPDATE --


update : { onCreated : Matchup -> msg } -> Msg -> Model -> ( Model, Cmd Msg, Maybe msg )
update { onCreated } action model =
    let
        withNothing s =
            ( s, Cmd.none, Nothing )
    in
    case ( model, action ) of
        ( PrepareFirst opponent ({ first } as state) creator, CreatorMsg msg ) ->
            let
                ( creator_, cmd, maybeMsg ) =
                    EnvCreator.update
                        { onCreated =
                            \{ env } ->
                                Ready
                                    { state | first = { first | env = env } }
                        }
                        msg
                        creator
            in
            case maybeMsg of
                Nothing ->
                    ( PrepareFirst opponent state creator_
                    , Cmd.map CreatorMsg cmd
                    , Nothing
                    )

                Just msg2 ->
                    update { onCreated = onCreated }
                        msg2
                        (PrepareFirst opponent state creator_)

        ( PrepareFirst opponent _ _, Ready state ) ->
            let
                ( creator_, cmd ) =
                    EnvCreator.init state.second.level

                withControls env =
                    case opponent of
                        Human ->
                            Env.withControls Controls.wasd env

                        Bot ->
                            Env.withControls Controls.arrows env

                state_ =
                    mapPlayer First (mapEnv withControls) state
            in
            ( PrepareSecond opponent state_ creator_
            , Cmd.map CreatorMsg cmd
            , Nothing
            )

        ( PrepareSecond opponent ({ first, second } as state) creator, CreatorMsg msg ) ->
            if first.level == second.level then
                update { onCreated = onCreated }
                    -- reuse generated env so the game is fair
                    (Ready { state | second = { second | env = first.env } })
                    (PrepareSecond opponent state creator)

            else
                let
                    ( creator_, cmd, maybeMsg ) =
                        EnvCreator.update
                            { onCreated =
                                \{ env } ->
                                    Ready
                                        { state | second = { second | env = env } }
                            }
                            msg
                            creator
                in
                case maybeMsg of
                    Nothing ->
                        ( PrepareSecond opponent state creator_
                        , Cmd.map CreatorMsg cmd
                        , Nothing
                        )

                    Just msg2 ->
                        update { onCreated = onCreated }
                            msg2
                            (PrepareSecond opponent state creator_)

        ( PrepareSecond opponent _ _, Ready state ) ->
            let
                withControls bottle_ =
                    case opponent of
                        Human ->
                            Env.withControls Controls.arrows bottle_

                        Bot ->
                            Env.withBot Bot.trashBot bottle_

                state_ =
                    mapPlayer Second (mapEnv withControls) state
            in
            ( Created state_, Cmd.none, Just (onCreated state_) )

        ( Created _, _ ) ->
            model |> withNothing
