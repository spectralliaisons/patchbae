module Views.Header exposing (..)

import Models.Patchbae exposing (Model, UserState(..))
import Msg.PatchMsg exposing (Msg(..))
import Models.Style as Style exposing (Size)
import Models.Txt as Txt
import Utils.ColorUtils exposing (fromHex, elmUIColorFromHex)
import Views.Shared exposing (text_)

import Html exposing (..)
import Html.Attributes as A exposing (style)
import Element
import Element.Font as Font
import Element.Background as Background
import Element.Input as Input

view : Model -> Html Msg
view model = Element.layout [] <|
    Element.row
        [ Font.color <| elmUIColorFromHex Style.colorSystemFont
        , Background.color <| elmUIColorFromHex Style.colorHeaderBg
        , Style.sizeFontMed
        , Style.fontFamilyPatch
        , Element.padding <| Style.paddingTiny
        , Element.width <| Element.px model.size.width
        -- , Element.height <| Element.px Style.heightHeader
        , Font.italic
        ]
        [ drawLogo
        , Element.el 
            [ Font.bold ]
            <| Element.text Txt.title
        , drawMenu model
        ]

drawLogo : Element.Element Msg
drawLogo = 
    Element.el
        [ Element.width <| Element.px <| Style.sizeLogoSm + Style.paddingTiny
        ]
        <| Element.html <| img [A.src "./rsc/patchbae.png", A.width Style.sizeLogoSm, A.height Style.sizeLogoSm] []

drawMenu : Model -> Element.Element Msg
drawMenu model = 
    let
        drawChangeUserState = case model.user of
            LoggedIn _ -> drawLogOut
            _ -> drawLogIn
    in 
        Element.row
            [ Element.width <| Element.px <| model.size.width
            ]
            [ Element.row
                [ Element.moveRight <| toFloat Style.paddingTiny
                , Style.sizeFontSm
                , Style.fontFamilyPatch
                ]
                [ Element.text Txt.motto
                ]
            , Element.el
                [ Element.alignRight
                , Element.moveLeft <| toFloat Style.widthHeaderLogInOut
                ]
                drawChangeUserState
            ]

drawLogOut : Element.Element Msg
drawLogOut =
    Input.button
        [ Element.mouseOver
            [ Background.color <| elmUIColorFromHex Style.colorBg
            ]
        , Font.italic
        ]
        { label = text_ Txt.logOut
        , onPress = Just LogOut
        }

drawLogIn : Element.Element Msg
drawLogIn =
    Input.button
        [ Element.mouseOver
            [ Background.color <| elmUIColorFromHex Style.colorBg
            ]
        , Font.italic
        ]
        { label = text_ Txt.logIn
        , onPress = Just LogOut
        }