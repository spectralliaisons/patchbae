module Models.Patchbae exposing (..)

import Browser.Navigation as Navigation

import Models.Style exposing (Size)

import InfiniteList
import Debug exposing (log)

type alias Model =
    { infiniteList : InfiniteList.Model
    , key : Navigation.Key
    , size : Maybe Size
    , patches : List Patch
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

type alias Patches = List Patch

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

type Direction = Up | Down | NoDirection
type Sortable = SortByInstrument Direction | SortByCategory Direction | SortByAddress Direction | SortByName Direction | SortByRating Direction

-- True if this patch would not conflict with existing entries
isUnique : Patch -> List Patch -> Bool
isUnique patchA patches =
    if List.length patches == 1 then True
    else
        let 
            notInitial = 
                patchA.instrument /= initPatch.instrument &&
                patchA.category /= initPatch.category &&
                patchA.address /= initPatch.address &&
                patchA.name /= initPatch.name
        in 
            patches
            |> List.filter (\{id} -> id /= patchA.id)
            |> List.foldl (\patchB acc -> acc && different patchA patchB) notInitial

different : Patch -> Patch -> Bool
different patchA patchB =
    patchA.instrument /= patchB.instrument ||
    patchA.category /= patchB.category ||
    patchA.address /= patchB.address ||
    patchA.name /= patchB.name

mostRecentIDInt : Patches -> Int
mostRecentIDInt patches =
    patches
    |> List.foldl (\{id} acc -> 
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