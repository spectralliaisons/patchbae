module Models.Api exposing (..)

import Models.Patchbae exposing (Patches)

import Json.Decode as D exposing (Decoder, int, string, list)
import Json.Decode.Pipeline exposing (required)
import Models.Patchbae exposing (Patch)

------------------------------------
--
-- DECODING & INTEGRATING RESPONSE
--

decodePatches : String -> Patches
decodePatches res =
    case D.decodeString (list patchDecoder) res of
        Ok result -> result
        _ ->  []

patchDecoder : D.Decoder Patch
patchDecoder =
    D.succeed Patch
        |> required "id" int
        |> required "instrument" string
        |> required "category" string
        |> required "address" string
        |> required "name" string
        |> required "rating" int
        |> required "tags" (list string)
        |> required "projects" (list string)
        |> required "family" (list int)
        |> required "friends" (list int)