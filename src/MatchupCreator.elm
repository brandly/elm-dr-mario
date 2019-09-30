module MatchupCreator exposing
    ( Matchup
    , Model(..)
    , Msg(..)
    , Opponent(..)
    , Player
    , Position(..)
    , init
    , mapBottle
    , mapPlayer
    , update
    )

import Bot
import Bottle exposing (Color(..), Speed(..))
import BottleCreator
import Component
import Controls
import Element exposing (Element, none, styled)
import Html exposing (Html, div, h3, p, span, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


type alias Player =
    { bottle : Bottle.Model
    , level : Int
    , speed : Speed
    }


mapBottle : (Bottle.Model -> Bottle.Model) -> Player -> Player
mapBottle map player =
    { player | bottle = map player.bottle }


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


getPlayer : Position -> Matchup -> Player
getPlayer position { first, second } =
    case position of
        First ->
            first

        Second ->
            second


mapPlayer : Position -> (Player -> Player) -> Matchup -> Matchup
mapPlayer position map state =
    case position of
        First ->
            { state | first = map state.first }

        Second ->
            { state | second = map state.second }


type Model
    = PrepareFirst Opponent Matchup BottleCreator.Model
    | PrepareSecond Opponent Matchup BottleCreator.Model
    | Created Matchup


type Msg
    = CreatorMsg BottleCreator.Msg
    | Ready Matchup


type BottleMsg
    = FirstBottleMsg Bottle.Msg
    | SecondBottleMsg Bottle.Msg


type alias Options =
    { level : Int
    , speed : Speed
    }


init : Opponent -> Options -> Options -> ( Model, Cmd Msg )
init opponent first second =
    let
        ( creator, cmd ) =
            BottleCreator.init first.level

        withOpts : Options -> Player
        withOpts opts =
            { level = opts.level
            , speed = opts.speed
            , bottle = Bottle.init
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
        ( PrepareFirst opponent ({ first, second } as state) creator, CreatorMsg msg ) ->
            let
                ( creator_, cmd, maybeMsg ) =
                    BottleCreator.update
                        { onCreated =
                            \{ bottle } ->
                                Ready
                                    { state | first = { first | bottle = bottle } }
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
                    BottleCreator.init state.second.level

                withControls bottle =
                    case opponent of
                        Human ->
                            Bottle.withControls Controls.wasd bottle

                        Bot ->
                            Bottle.withControls Controls.arrows bottle

                state_ =
                    mapPlayer First (mapBottle withControls) state
            in
            ( PrepareSecond opponent state_ creator_
            , Cmd.map CreatorMsg cmd
            , Nothing
            )

        ( PrepareSecond opponent ({ first, second } as state) creator, CreatorMsg msg ) ->
            if first.level == second.level then
                update { onCreated = onCreated }
                    -- reuse generated bottle so the game is fair
                    (Ready { state | second = { second | bottle = first.bottle } })
                    (PrepareSecond opponent state creator)

            else
                let
                    ( creator_, cmd, maybeMsg ) =
                        BottleCreator.update
                            { onCreated =
                                \{ bottle } ->
                                    Ready
                                        { state | second = { second | bottle = bottle } }
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
                            Bottle.withControls Controls.arrows bottle_

                        Bot ->
                            Bottle.withBot Bot.trashBot bottle_

                state_ =
                    mapPlayer Second (mapBottle withControls) state
            in
            ( Created state_, Cmd.none, Just (onCreated state_) )

        ( Created _, _ ) ->
            model |> withNothing
