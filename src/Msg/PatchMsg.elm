module Msg.PatchMsg exposing (Msg(..))

import Models.Patchbae exposing (Patch, Patches, Sortable(..))
import Models.Style exposing (Size)

import InfiniteList
import Url
import Browser

type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | SetSize Size
    | SetPatchInstrument Patch String
    | SetPatchCategory Patch String
    | SetPatchAddress Patch String
    | SetPatchName Patch String
    | SetPatchRating Patch Int
    | AddPatch
    | RmPatch Patch
    | SortBy Sortable
    | InfiniteListMsg InfiniteList.Model