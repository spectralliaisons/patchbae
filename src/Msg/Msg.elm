module Msg.Msg exposing (Msg(..))

import Url
import Browser
import Http

type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | Initialize Size
    | SetSize Size