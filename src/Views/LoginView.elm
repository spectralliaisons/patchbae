module Views.LoginView exposing (..)

import Models.Txt as Txt
import Models.Style as Style exposing (Size)
import Utils.ColorUtils exposing (fromHex, elmUIColorFromHex)
import Views.Shared exposing (text_)

import Msg.PatchMsg exposing (Msg(..))
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

view : Size -> String -> String -> Html Msg
view size username password = Element.layout [] <|
    Element.column
        [ Font.color <| elmUIColorFromHex Style.colorSystemFont
        , Background.color <| elmUIColorFromHex Style.colorInputBg
        , Style.sizeFontMed
        , Style.fontFamilyPatch
        , Element.padding <| Style.paddingMedium
        , Element.width <| Element.px size.width
        , Element.height <| Element.px size.height
        , Element.spacing Style.paddingMedium
        ]
        [ drawLogo
        , Element.el
            [ Element.centerX
            , Element.padding Style.paddingMedium
            , Font.bold
            ]
            <| text_ Txt.loginTitle
        , Element.column
            [ Element.padding Style.paddingMedium
            , Element.spacing Style.paddingMedium
            , Element.centerX
            ]
            [ ELazy.lazy4 drawTextInput size Txt.login username SetLogin
            , ELazy.lazy4 drawTextInput size Txt.password password SetPassword
            , drawLogIn
            ]
        , Element.el
            [ Element.moveDown <| toFloat Style.paddingMedium
            , Element.centerX
            ]
            drawSkip
        ]

drawLogo : Element.Element Msg
drawLogo =
    Element.el
        [ Element.width <| Element.px <| Style.sizeLogoLg + Style.paddingTiny
        , Element.centerX
        ]
        <| Element.html <| img [A.src "./rsc/patchbae-lg.png", A.width Style.sizeLogoLg, A.height Style.sizeLogoLg] []

drawTextInput : Size -> String -> String -> (String -> Msg) -> Element.Element Msg
drawTextInput size label txt cmd =
    Input.text
        [ Font.color <| elmUIColorFromHex Style.colorSystemFont
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
        , Element.centerX
        , Element.width <| Element.px <| Style.widthLogin
        , Element.mouseOver 
            [ Border.color <| elmUIColorFromHex Style.colorBorderFocused
            ]
        ]
        { onChange = cmd
        , text = txt
        , placeholder = Nothing
        , label = 
            Input.labelAbove 
                [ Element.centerX
                ] 
                <| text_ label
        }

drawLogIn : Element.Element Msg
drawLogIn =
    Input.button
        [ Element.mouseOver
            [ Background.color <| elmUIColorFromHex Style.colorBg
            ]
        , Element.centerX
        , Font.italic
        , Font.bold
        ]
        { label = text_ Txt.logIn
        , onPress = Just LogIn
        }
drawSkip : Element.Element Msg
drawSkip =
    Input.button
        [ Element.mouseOver
            [ Background.color <| elmUIColorFromHex Style.colorBg
            ]
        , Element.centerX
        , Font.italic
        , Font.bold
        ]
        { label = text_ Txt.skipLogin
        , onPress = Just SkipLogin
        }