module Models.Style exposing (..)

import Element
import Element.Font as Font

type alias Size = 
    { width : Int
    , height : Int
    }

smallScreen : Size -> Bool
smallScreen {width} = width < 950

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

colorMutedFont : String
colorMutedFont = "#525045"

colorBorderFocused : String
colorBorderFocused = colorSystemFont

colorBorderUnfocused : String
colorBorderUnfocused = colorBg

colorInputBg : String
colorInputBg = colorBg

colorHeaderBg : String
colorHeaderBg = "#2a2a2a"

colorErrorMessage : String
colorErrorMessage = "#ff0066"

------------------------------------
--
-- SIZES
--

sizeFontMed : Element.Attr decorative message
sizeFontMed = Font.size 18

sizeFontSm : Element.Attr decorative message
sizeFontSm = Font.size 14

heightButton : Int
heightButton = 40

heightStar : Int
heightStar = 30

spacingStars : Int
spacingStars = -5

widthColumn : Int
widthColumn = 250

borderRounding : Int
borderRounding = 0

widthBorderInput : Int
widthBorderInput = 2

paddingMedium : Int
paddingMedium = 25

paddingTiny : Int
paddingTiny = 5

heightIconSort : Int
heightIconSort = 18

sizeLogoSm : Int
sizeLogoSm = 40

widthLogin : Int
widthLogin = 250

heightHeader : Int
heightHeader = 50

widthHeaderLogInOut : Int
widthHeaderLogInOut = 150

sizeLogoLg : Int
sizeLogoLg = 125

heightIconWait : Int
heightIconWait = 50

offsetLogInFailedMessage : Int
offsetLogInFailedMessage = 75