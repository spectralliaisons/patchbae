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
    -- LOGIN
    | SetLogin String
    | SetPassword String
    | LogIn
    | SkipLogin
    -- HEADER
    | LogOut
    -- PATCHES
    | InfiniteListMsg InfiniteList.Model
    | SetPatchInstrument Patch String
    | SetPatchCategory Patch String
    | SetPatchAddress Patch String
    | SetPatchName Patch String
    | SetPatchRating Patch Int
    | AddPatch
    | RmPatch Patch
    | SortBy Sortable