module Models.Patchbae exposing (..)

import Browser.Navigation as Navigation

import Models.Style exposing (Size)

import Json.Decode as D exposing (string, list, array, maybe, int)
import Json.Decode.Pipeline exposing (required)
import Array exposing (Array)
import InfiniteList
import Time

type alias Model =
    { infiniteList : InfiniteList.Model
    , lastChange : Maybe Time.Posix
    , key : Navigation.Key
    , size : Size
    , user : UserState
    , patches : Patches
    }

type alias Patch = 
    { id : String
    , instrument : String
    , category : String
    , address : String
    , name : String
    , rating : Int
    , tags : List String
    , projects : List String
    , family : List Int
    , friends : List Int
    }

type alias Patches = Array Patch

type alias UID = Maybe String

type UserState = LoggedIn String | LoggedOut String String | LoggingIn | FailedLogIn String String String | Guest

type alias UserData = 
    { uid : UID
    , patches : Patches
    }

userDataDecoder : D.Decoder UserData
userDataDecoder = 
    D.succeed UserData
    |> required "uid" uidDecoder
    |> required "patches" (array patchDecoder)

uidDecoder : D.Decoder UID
uidDecoder = maybe string

patchDecoder : D.Decoder Patch
patchDecoder = 
    D.succeed Patch
    |> required "id" string
    |> required "instrument" string
    |> required "category" string
    |> required "address" string
    |> required "name" string
    |> required "rating" int
    |> required "tags" (list string)
    |> required "projects" (list string)
    |> required "family" (list int)
    |> required "friends" (list int)

initPatch : Patch
initPatch = Patch
    "0" -- id
    "" -- instrument
    "" -- category
    "" -- address
    "" -- name
    2 -- rating
    [] -- tags
    [] -- projects
    [] -- family
    [] -- friends

initPatches : Patches
initPatches = 
    Array.fromList [initPatch]

type Direction = Up | Down | NoDirection
type Sortable = SortByInstrument Direction | SortByCategory Direction | SortByAddress Direction | SortByName Direction | SortByRating Direction

-- True if this patch would not conflict with existing entries
isUnique : Patch -> Patches -> Bool
isUnique patchA patches =
    if Array.length patches == 1 then True
    else
        let 
            notInitial = 
                patchA.instrument /= initPatch.instrument &&
                patchA.category /= initPatch.category &&
                patchA.address /= initPatch.address &&
                patchA.name /= initPatch.name
        in 
            patches
            |> Array.filter (\{id} -> id /= patchA.id)
            |> Array.foldl (\patchB acc -> acc && different patchA patchB) notInitial

different : Patch -> Patch -> Bool
different patchA patchB =
    patchA.instrument /= patchB.instrument ||
    patchA.category /= patchB.category ||
    patchA.address /= patchB.address ||
    patchA.name /= patchB.name

mostRecentIDInt : Patches -> Int
mostRecentIDInt patches =
    patches
    |> Array.foldl (\{id} acc -> 
        max acc <| Maybe.withDefault acc <| String.toInt id
    ) 0

sortBy : Patches -> Sortable -> Patches
sortBy patches how =
    case how of
        SortByInstrument direction -> patches
        SortByCategory direction -> patches
        SortByAddress direction -> patches
        SortByName direction -> patches
        SortByRating direction -> patches