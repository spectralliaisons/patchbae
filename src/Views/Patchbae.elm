module Views.Patchbae exposing (..)

import Models.Patchbae exposing (Patch)
import Msg.Patchbae exposing (Msg(..))

import Html exposing (..)
import Element

view : List Patch -> Html Msg
view patches =
    Element.layout
        []
        Element.none