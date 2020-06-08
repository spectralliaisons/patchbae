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

colorBg : String
colorBg = "#1d1d1d"

colorSystemFont : String
colorSystemFont = "#9d9d9d"

colorInputBg : String
colorInputBg = "#1d1d1d"

------------------------------------
--
-- SIZES
--

sizeFontMed : Element.Attr decorative message
sizeFontMed = Font.size 18

heightRow : Int
heightRow = 50

heightStar : Int
heightStar = 30

spacingStars : Int
spacingStars = -5

widthColInstrument : Int
widthColInstrument = 150

borderRoundingLg : Int
borderRoundingLg = 50

widthBorderInput : Int
widthBorderInput = 2

paddingMedium : Int
paddingMedium = 25

paddingTiny : Int
paddingTiny = 5