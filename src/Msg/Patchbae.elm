module Msg.Patchbae exposing (Msg(..))

import Models.Patchbae exposing (Patch)
import Models.Style exposing (Size)

import Url
import Browser
import Http

type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | Initialize Size
    | SetSize Size
    | SetPatchInstrument Patch String
    | SetPatchCategory Patch String