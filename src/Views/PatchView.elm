module Views.PatchView exposing (..)

import Models.Patchbae exposing (Model, Patch, isUnique, Sortable(..), Direction(..))
import Models.Txt as Txt
import Models.Style as Style exposing (Size)
import Msg.PatchMsg exposing (Msg(..))
import Utils.ColorUtils exposing (fromHex, elmUIColorFromHex)
import Views.Icons as Icons

import Html exposing (..)
import Html.Attributes as A exposing (style)
import Html.Lazy as HLazy
import Element
import Element.Keyed as Keyed
import Element.Lazy as ELazy
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Element.Font as Font

import Debug exposing (log)
import Models.Txt exposing (category)
import Element exposing (fill)
import Html.Events exposing (onSubmit)
import InfiniteList
import Array exposing (Array)

maxRating : Int
maxRating = 5

rowHeight : Int
rowHeight = (Style.paddingMedium + Style.paddingTiny) * 2

config : Model -> InfiniteList.Config String Msg
config model =
    let
        screenHeight = case model.size of
            Nothing -> 0
            Just {height} -> height
    in InfiniteList.config
        { itemView = itemView model
        , itemHeight = InfiniteList.withConstantHeight rowHeight
        , containerHeight = screenHeight
        }
        |> InfiniteList.withOffset screenHeight

view : Model -> Html Msg
view model =
    case model.size of
        Nothing -> div [] []
        Just size -> 
            div
                [ 
                ]
                [ HLazy.lazy drawHeader size
                , HLazy.lazy2 drawScrollView size model
                ]

drawHeader : Size -> Html Msg
drawHeader size = 
    Element.layout 
        [ 
        ]
        <| Element.row
            [ Font.color <| elmUIColorFromHex Style.colorSystemFont
            , Background.color <| elmUIColorFromHex Style.colorHeaderBg
            , Style.sizeFontMed
            , Style.fontFamilyPatch
            , Element.padding <| Style.paddingTiny
            , Element.width <| Element.px size.width
            ]
            [ Element.text Txt.title
            ]

drawScrollView : Size -> Model -> Html Msg
drawScrollView {height} model = 
    div 
        [ style "background-color" Style.colorBg 
        ] 
        [ div
            [ style "width" "100%"
            , style "height" (String.fromInt height ++ "px")
            , style "overflow-x" "hidden"
            , style "overflow-y" "auto"
            , style "-webkit-overflow-scrolling" "touch"
            , InfiniteList.onScroll InfiniteListMsg
            ]
            [ HLazy.lazy3 
                InfiniteList.view 
                    (config model) 
                    model.infiniteList 
                    (List.map .id (Array.toList model.patches))
            ]
        ]

itemView : Model -> Int -> Int -> String -> Html Msg
itemView model idx listIdx item =
    Element.layout []
    <| case model.size of
        Nothing -> Element.none
        Just size ->
            case Array.get listIdx model.patches of
                Nothing -> Element.none
                Just patch ->
                    ELazy.lazy4 drawRows size (isUnique patch model.patches) listIdx patch

drawRows : Size -> Bool -> Int -> Patch -> Element.Element Msg
drawRows size unique i patch =
    let
        which = if Style.smallScreen size then Element.column else Element.row
        topRow = i == 0
        -- drawID id =
        --     Element.el 
        --         [ Font.color <| elmUIColorFromHex Style.colorMutedFont
        --         , Style.sizeFontSm
        --         , Style.fontFamilyPatch
        --         , Element.moveDown <| toFloat Style.paddingMedium
        --         ]
        --         (Element.text id)
        -- only the top row has headers
        controls = 
            if topRow then
                ELazy.lazy drawButtonAddPatch unique
            else
                ELazy.lazy drawButtonRmPatch patch
    in
        which
            [ Element.spacing Style.paddingMedium
            , Element.padding Style.paddingTiny
            , Element.centerX
            ]
            -- [ ELazy.lazy drawID patch.id
            [ ELazy.lazy5 drawTextInput topRow (getHeader i Txt.instrument) (SortByInstrument NoDirection) patch.instrument (SetPatchInstrument patch)
            , ELazy.lazy5 drawTextInput topRow (getHeader i Txt.category) (SortByCategory NoDirection) patch.category (SetPatchCategory patch)
            , ELazy.lazy5 drawTextInput topRow (getHeader i Txt.address) (SortByAddress NoDirection) patch.address (SetPatchAddress patch)
            , ELazy.lazy5 drawTextInput topRow (getHeader i Txt.name) (SortByName NoDirection) patch.name (SetPatchName patch)
            , ELazy.lazy3 drawRating (getHeader i Txt.rating) (SortByRating NoDirection) patch
            , controls
            ]

getHeader : Int -> String -> Maybe String
getHeader i s = if i == 0 then Just s else Nothing

drawTextInput : Bool -> Maybe String -> Sortable -> String -> (String -> Msg) -> Element.Element Msg
drawTextInput topRow l howToSort txt cmd =
    let
        labl = case l of
            Nothing -> 
                Input.labelHidden ""
            Just str -> 
                Input.labelAbove 
                    [ Element.centerX
                    ] 
                    <| button_ str (Just <| SortBy howToSort)
        
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

button_ : String -> Maybe Msg -> Element.Element Msg
button_ str msg =
    Input.button
        [ Element.padding Style.paddingTiny
        , Element.mouseOver
            [ Background.color <| elmUIColorFromHex Style.colorBg
            ]
        ]
        { label = 
            Element.row
                []
                [ text_ str
                , Element.el
                    [ Element.moveRight <| toFloat Style.paddingTiny
                    ]
                    Icons.iconSort
                ]
        , onPress = msg
        }

drawRating : Maybe String -> Sortable -> Patch ->  Element.Element Msg
drawRating l howToSort patch =
    let
        labl = case l of
            Nothing -> 
                Element.none
            Just str -> 
                Element.el
                    [ Element.centerX
                    ] 
                    <| button_ str (Just <| SortBy howToSort)
        stars =
            List.range 1 maxRating
            |> List.map (\i ->
                ELazy.lazy3 Icons.btnStar i patch.rating <| Just <| SetPatchRating patch i
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