module Views.Icons exposing (..)

import Models.Style as Style
import Utils.ColorUtils exposing (fromHex, elmUIColorFromHex)

import Color
import Material.Icons as Filled
import Material.Icons.Types exposing (Coloring(..))
import TypedSvg.Core exposing (Svg)
import Element
import Element.Input as Input
import Element.Background as Background
import Element.Border as Border

colorButton : Coloring
colorButton = 
    Color <| fromHex Style.colorSystemFont

button : Maybe msg -> Svg msg -> Element.Element msg
button evt icon = 
  Input.button
    [ Element.padding Style.paddingTiny
    , Element.mouseOver
        [ Background.color <| elmUIColorFromHex Style.colorBgDark
        ]
    ]
    { label = Element.html icon
    , onPress = evt
    }

btnAdd : Maybe msg -> Element.Element msg
btnAdd cmd = 
    button cmd
    <| Filled.add Style.sizeButton colorButton

btnRm : Maybe msg -> Element.Element msg
btnRm cmd = 
    button cmd
    <| Filled.remove Style.sizeButton colorButton