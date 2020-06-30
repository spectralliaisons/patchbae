module Models.Patchbae exposing (..)

import Browser.Navigation as Navigation

import Models.Style exposing (Size)

import Array exposing (Array)
import InfiniteList
import Debug exposing (log)

type alias Model =
    { infiniteList : InfiniteList.Model
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

type alias UserData = 
    { uid : UID
    , patches : Patches
    }

type UserState = LoggedIn String | LoggedOut String String | Guest

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