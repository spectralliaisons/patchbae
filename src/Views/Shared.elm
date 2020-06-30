module Views.Shared exposing (..)

import Models.Style as Style
import Utils.ColorUtils exposing (elmUIColorFromHex)

import Element
import Element.Font as Font

text_ : String -> Element.Element msg
text_ str = 
  Element.el 
    [ Font.color <| elmUIColorFromHex Style.colorSystemFont
    , Style.sizeFontMed
    , Style.fontFamilyPatch
    ]
    (Element.text str)