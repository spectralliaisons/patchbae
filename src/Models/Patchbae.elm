module Models.Patchbae exposing (..)

import Browser.Navigation as Navigation

import Models.Style exposing (Size)

import Debug exposing (log)

type alias Model =
    { key : Navigation.Key
    , size : Maybe Size
    , lastID : String
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
    "unset" -- id
    "" -- instrument
    "" -- category
    "" -- address
    "" -- name
    2 -- rating
    [] -- tags
    [] -- projects
    [] -- family
    [] -- friends

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