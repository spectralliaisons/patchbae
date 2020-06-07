module Models.Patchbae exposing (..)

import Browser.Navigation as Navigation
import Set exposing (Set)

import Models.Style exposing (Size)

type alias Model =
    { key : Navigation.Key
    , size : Maybe Size
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
    "fkinstr" -- instrument
    "fkcat" -- category
    "fkaddr" -- address
    "fknm" -- name
    0 -- rating
    (Set.fromList []) -- tags
    (Set.fromList []) -- projects
    [] -- family
    [] -- friends