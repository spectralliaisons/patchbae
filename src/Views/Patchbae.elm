module Views.Patchbae exposing (..)

import Models.Patchbae exposing (Patch)
import Models.Txt as Txt
import Models.Style as Style exposing (Size)
import Msg.Patchbae exposing (Msg(..))
import Utils.ColorUtils exposing (fromHex, elmUIColorFromHex)
import Views.Icons as Icons

import Html exposing (..)
import Element
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Element.Font as Font

import Debug exposing (log)

view : Maybe Size -> List Patch -> Html Msg
view s patches = Element.layout [] <|
    case s of
        Nothing -> Element.none
        Just size ->
            let
                els = 
                    List.indexedMap (drawRows size) patches
                    |> List.append [ drawTitle ]
            in
                Element.column
                    []
                    els

drawTitle : Element.Element Msg
drawTitle =
  Element.el 
    [ Font.color <| elmUIColorFromHex Style.colorSystemFont
    , Style.sizeFontMed
    , Style.fontFamilyPatch
    , Element.centerX
    , Element.moveDown <| toFloat Style.paddingMedium
    , Element.padding Style.paddingMedium
    ]
    (Element.text Txt.title)

drawRows : Size -> Int -> Patch -> Element.Element Msg
drawRows size i patch =
    let
        _ = log "drawRows i" i
        controls =
            if i == 0 then
                drawButtonAddPatch
            else
                drawButtonRmPatch patch
    in
        Element.row
            [ Element.padding Style.paddingMedium
            , Element.spacing Style.paddingMedium
            ]
            [ drawTextInput Txt.instrument patch.instrument (SetPatchInstrument patch)
            , drawTextInput Txt.category patch.category (SetPatchCategory patch)
            , drawTextInput Txt.address patch.address (SetPatchAddress patch)
            , drawTextInput Txt.name patch.name (SetPatchAddress patch)
            , controls
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
        , label = Input.labelAbove 
            [ Element.centerX
            ] 
            <| text_ label
        }

text_ : String -> Element.Element Msg
text_ str = 
  Element.el 
    [ Font.color <| elmUIColorFromHex Style.colorSystemFont
    , Style.sizeFontMed
    , Style.fontFamilyPatch
    ]
    (Element.text str)

drawButtonAddPatch : Element.Element Msg
drawButtonAddPatch =
   Element.el
    [ Element.padding Style.paddingMedium
    , Element.height <| Element.px Style.heightRow
    ]
    (Icons.btnAdd <| Just AddPatch)

drawButtonRmPatch : Patch -> Element.Element Msg
drawButtonRmPatch patch =
   Element.el
    [ Element.padding Style.paddingMedium
    , Element.height <| Element.px Style.heightRow
    ]
    (Icons.btnRm <| Just <| RmPatch patch)