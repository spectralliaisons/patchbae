module Msg.Patchbae exposing (Msg(..), Size)

import Url
import Browser
import Http

type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | Initialize Size
    | SetSize Size

type alias Size = 
    { width : Int
    , height : Int
    }