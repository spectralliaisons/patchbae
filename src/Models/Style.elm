module Models.Style exposing (..)

import Element
import Element.Font as Font

type alias Size = 
    { width : Int
    , height : Int
    }

smallScreen : Size -> Bool
smallScreen {width} = width < 925

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
colorSystemFont = "#a3a091"

colorBorderFocused : String
colorBorderFocused = colorSystemFont

colorBorderUnfocused : String
colorBorderUnfocused = colorBg

colorInputBg : String
colorInputBg = colorBg

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

widthColumn : Int
widthColumn = 200

borderRounding : Int
borderRounding = 0

widthBorderInput : Int
widthBorderInput = 2

paddingMedium : Int
paddingMedium = 25

paddingTiny : Int
paddingTiny = 5