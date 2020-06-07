module Views.Patchbae exposing (..)

import Models.Patchbae exposing (Patch)
import Models.Txt as Txt
import Models.Style as Style exposing (Size)
import Msg.Patchbae exposing (Msg(..))
import Utils.ColorUtils exposing (fromHex, elmUIColorFromHex)

import Html exposing (..)
import Element
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Element.Font as Font

view : Maybe Size -> List Patch -> Html Msg
view s patches = Element.layout [] <|
    case s of
        Nothing -> Element.none
        Just size -> 
            Element.column
                []
                (List.indexedMap (drawPatch size) patches)

drawPatch : Size -> Int -> Patch -> Element.Element Msg
drawPatch size i patch =
    Element.row
        [ Element.padding Style.paddingMedium
        , Element.spacing Style.paddingMedium
        ]
        [ drawTextInput Txt.instrument patch.instrument (SetPatchInstrument patch)
        , drawTextInput Txt.category patch.category (SetPatchCategory patch)
        ]

drawTextInput : String -> String -> (String -> Msg) -> Element.Element Msg
drawTextInput label txt cmd =
    Input.text
        [ Font.color <| elmUIColorFromHex Style.colorSystemFont
        , Style.sizeFontMed
        , Style.fontFamilyPatch
        , Element.width <| Element.px Style.widthColInstrument
        , Element.height <| Element.px Style.heightRow
        , Background.color <| elmUIColorFromHex Style.colorInputBg
        , Border.rounded Style.borderRoundingLg
        , Border.width Style.widthBorderInput
        ]
        { onChange = cmd
        , text = txt
        , placeholder = Nothing
        , label = Input.labelAbove [] <| text_ label
        }

text_ : String -> Element.Element Msg
text_ str = 
  Element.el 
    [ Font.color <| elmUIColorFromHex Style.colorSystemFont
    , Style.sizeFontMed
    , Style.fontFamilyPatch
    ]
    (Element.text str)