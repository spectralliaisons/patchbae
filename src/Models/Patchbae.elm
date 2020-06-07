module Models.Patchbae exposing (..)

import Browser.Navigation as Navigation
import Msg.Patchbae exposing (Size)

type alias Model =
    { key : Navigation.Key
    , size : Maybe Size
    , patches : List Patch
    }

type alias Patch = 
    { 
    }