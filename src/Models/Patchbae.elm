module Models.Patchbae exposing (..)

import Browser.Navigation as Navigation
import Set exposing (Set)

import Models.Style exposing (Size)

import Debug exposing (log)

type alias Model =
    { key : Navigation.Key
    , size : Maybe Size
    , lastID : Int
    , patches : List Patch
    }

type alias Patch = 
    { id : Int
    , instrument : String
    , category : String
    , address : String
    , name : String
    , rating : Int
    , tags : Set String
    , projects : Set String
    , family : List Int
    , friends : List Int
    }

initPatch : Patch
initPatch = Patch
    0 -- id
    "" -- instrument
    "" -- category
    "" -- address
    "" -- name
    1 -- rating
    (Set.fromList []) -- tags
    (Set.fromList []) -- projects
    [] -- family
    [] -- friends

uniquelyValid : Patch -> List Patch -> Bool
uniquelyValid patchA patches =
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