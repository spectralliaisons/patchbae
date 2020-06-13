module Views.Patchbae exposing (..)

import Models.Patchbae exposing (Patch, isUnique)
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
import Models.Txt exposing (category)
import Element exposing (fill)

maxRating : Int
maxRating = 5

view : Maybe Size -> List Patch -> Html Msg
view s patches = Element.layout [] <|
    case s of
        Nothing -> Element.none
        Just size ->
            let
                els = 
                    List.indexedMap (drawRows size patches) patches
                    |> List.append [ drawTitle ]
            in
                Element.column
                    [ Element.width <| Element.px size.width
                    , Element.height <| Element.px size.height
                    , Element.padding Style.paddingMedium
                    ]
                    els

drawTitle : Element.Element Msg
drawTitle =
  Element.el 
    [ Font.color <| elmUIColorFromHex Style.colorSystemFont
    , Style.sizeFontMed
    , Style.fontFamilyPatch
    , Element.centerX
    , Element.padding Style.paddingMedium
    ]
    (Element.text Txt.title)

drawRows : Size -> List Patch -> Int -> Patch -> Element.Element Msg
drawRows size patches i patch =
    let
        which = if Style.smallScreen size then Element.column else Element.row
        topRow = i == 0
        -- only the top row has headers
        controls =
            if topRow then
                drawButtonAddPatch <| isUnique patch patches
            else
                drawButtonRmPatch patch
    in
        which
            [ Element.spacing Style.paddingMedium
            , Element.padding Style.paddingTiny
            , Element.centerX
            ]
            [ drawTextInput topRow (getHeader i Txt.instrument) patch.instrument (SetPatchInstrument patch)
            , drawTextInput topRow (getHeader i Txt.category) patch.category (SetPatchCategory patch)
            , drawTextInput topRow (getHeader i Txt.address) patch.address (SetPatchAddress patch)
            , drawTextInput topRow (getHeader i Txt.name) patch.name (SetPatchName patch)
            , drawRating (getHeader i Txt.rating) patch
            , controls
            ]

getHeader : Int -> String -> Maybe String
getHeader i s = if i == 0 then Just s else Nothing

drawTextInput : Bool -> Maybe String -> String -> (String -> Msg) -> Element.Element Msg
drawTextInput topRow l txt cmd =
    let
        labl = case l of
            Nothing -> 
                Input.labelHidden ""
            Just str -> 
                Input.labelAbove 
                    [ Element.centerX
                    ] 
                    <| text_ str
        
        attrFocused = 
            [ Border.color <| elmUIColorFromHex Style.colorBorderFocused
            ]

        textAttributes = 
            if topRow then attrFocused
            else
                [ Border.color <| elmUIColorFromHex Style.colorBorderUnfocused
                ]
    in
        Input.text
            ([ Font.color <| elmUIColorFromHex Style.colorSystemFont
            , Style.sizeFontMed
            , Style.fontFamilyPatch
            , Background.color <| elmUIColorFromHex Style.colorInputBg
            , Border.rounded Style.borderRounding
            , Border.widthEach
                { bottom = Style.widthBorderInput
                , left = 0
                , top = 0
                , right = 0
                }
            , Element.mouseOver attrFocused
            ] ++ textAttributes)
            { onChange = cmd
            , text = txt
            , placeholder = Nothing
            , label = labl
            }

text_ : String -> Element.Element Msg
text_ str = 
  Element.el 
    [ Font.color <| elmUIColorFromHex Style.colorSystemFont
    , Style.sizeFontMed
    , Style.fontFamilyPatch
    ]
    (Element.text str)

drawRating : Maybe String -> Patch ->  Element.Element Msg
drawRating l patch =
    let
        labl = case l of
            Nothing -> 
                Element.none
            Just str -> 
                Element.el
                    [ Element.centerX
                    ] 
                    <| text_ str
        stars =
            List.range 1 maxRating
            |> List.map (\i ->
                Icons.btnStar i patch.rating <| Just <| SetPatchRating patch i
            )
    in
        Element.column
            [ Element.width <| Element.px Style.widthColumn
            ]
            [ labl
            , Element.row
                [ Element.width <| Element.px Style.widthColumn
                , Element.spacing Style.spacingStars
                ]
                stars 
            ]

drawButtonAddPatch : Bool -> Element.Element Msg
drawButtonAddPatch addable =
    Element.el
        -- [ Element.padding Style.paddingMedium
        [ Element.moveDown <| toFloat Style.heightButton / 4
        , Element.centerX
        ]
        (Icons.btnAdd addable <| Just AddPatch)

drawButtonRmPatch : Patch -> Element.Element Msg
drawButtonRmPatch patch =
    Element.el
        -- [ Element.padding Style.paddingMedium
        [ Element.moveDown <| toFloat Style.heightButton / 4
        , Element.centerX
        ]
        (Icons.btnRm <| Just <| RmPatch patch)