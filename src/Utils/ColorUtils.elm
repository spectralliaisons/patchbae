module Utils.ColorUtils exposing (fromHex, elmUIColorFromHex)

-- TODO: delete this when fromHex is exposed in
-- https://github.com/avh4/elm-color/blob/1.0.0/src/Color.elm

import Color exposing (Color, rgba)
import Bitwise exposing (shiftLeftBy)
import Element

elmUIColorFromHex : String -> Element.Color
elmUIColorFromHex hex =
    let
        {red, green, blue, alpha } =
            Color.toRgba <| fromHex hex
    in
        Element.rgba red green blue alpha

{-| Returns a color represented by a valid 3- or 6-digit RGB hex string
or a 4- or 8-digit RGBA hex string.
String may (but are not required to) start with a `#` character.
Hex digits in the string may be either uppercase or lowercase.
If the input string is not a valid hex string, it will return `Nothing`.
    fromHex "#Ac3" --> Just (Color.rgb255 0xAA 0xCC 0x33)
    fromHex "ffe4e1" --> Just (Color.rgb255 0xFF 0xE4 0xE1)
    fromHex "#00ff00FF" --> Just (Color.rgba 0.0 1.0 0.0 1.0)
    fromHex "**purple**" --> Nothing
-}
fromHex : String -> Color
fromHex hexString =
    let 
        m = case String.toList hexString of
            [ '#', r, g, b ] ->
                fromHex8 ( r, r ) ( g, g ) ( b, b ) ( 'f', 'f' )

            [ r, g, b ] ->
                fromHex8 ( r, r ) ( g, g ) ( b, b ) ( 'f', 'f' )

            [ '#', r, g, b, a ] ->
                fromHex8 ( r, r ) ( g, g ) ( b, b ) ( a, a )

            [ r, g, b, a ] ->
                fromHex8 ( r, r ) ( g, g ) ( b, b ) ( a, a )

            [ '#', r1, r2, g1, g2, b1, b2 ] ->
                fromHex8 ( r1, r2 ) ( g1, g2 ) ( b1, b2 ) ( 'f', 'f' )

            [ r1, r2, g1, g2, b1, b2 ] ->
                fromHex8 ( r1, r2 ) ( g1, g2 ) ( b1, b2 ) ( 'f', 'f' )

            [ '#', r1, r2, g1, g2, b1, b2, a1, a2 ] ->
                fromHex8 ( r1, r2 ) ( g1, g2 ) ( b1, b2 ) ( a1, a2 )

            [ r1, r2, g1, g2, b1, b2, a1, a2 ] ->
                fromHex8 ( r1, r2 ) ( g1, g2 ) ( b1, b2 ) ( a1, a2 )

            _ ->
                Nothing
    in 
        case m of
            Just c -> c
            Nothing -> Color.black

fromHex8 : ( Char, Char ) -> ( Char, Char ) -> ( Char, Char ) -> ( Char, Char ) -> Maybe Color
fromHex8 ( r1, r2 ) ( g1, g2 ) ( b1, b2 ) ( a1, a2 ) =
    Maybe.map4
        (\r g b a ->
            rgba
                (toFloat r / 255)
                (toFloat g / 255)
                (toFloat b / 255)
                (toFloat a / 255)
        )
        (hex2ToInt r1 r2)
        (hex2ToInt g1 g2)
        (hex2ToInt b1 b2)
        (hex2ToInt a1 a2)

hex2ToInt : Char -> Char -> Maybe Int
hex2ToInt c1 c2 =
    Maybe.map2 (\v1 v2 -> shiftLeftBy 4 v1 + v2) (hexToInt c1) (hexToInt c2)

hexToInt : Char -> Maybe Int
hexToInt char =
    case Char.toLower char of
        '0' ->
            Just 0

        '1' ->
            Just 1

        '2' ->
            Just 2

        '3' ->
            Just 3

        '4' ->
            Just 4

        '5' ->
            Just 5

        '6' ->
            Just 6

        '7' ->
            Just 7

        '8' ->
            Just 8

        '9' ->
            Just 9

        'a' ->
            Just 10

        'b' ->
            Just 11

        'c' ->
            Just 12

        'd' ->
            Just 13

        'e' ->
            Just 14

        'f' ->
            Just 15

        _ ->
            Nothing
