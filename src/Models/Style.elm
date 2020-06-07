module Models.Style exposing (..)

import Element
import Element.Font as Font

type alias Size = 
    { width : Int
    , height : Int
    }

fontFamilyPatch : Element.Attribute message
fontFamilyPatch = 
  Font.family 
    [ Font.typeface "Open Sans"
    , Font.sansSerif
    ]

------------------------------------
--
-- COLORS
--

colorSystemFont : String
colorSystemFont = "#eeeeee"

colorInputBg : String
colorInputBg = "#000000"

------------------------------------
--
-- SIZES
--

sizeFontMed : Element.Attr decorative message
sizeFontMed = Font.size 18

heightRow : Int
heightRow = 50

widthColInstrument : Int
widthColInstrument = 150

borderRoundingLg : Int
borderRoundingLg = 50

widthBorderInput : Int
widthBorderInput = 2

paddingMedium : Int
paddingMedium = 25