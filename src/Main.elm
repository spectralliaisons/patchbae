module Main exposing (init, update)

import Html exposing (..)
import Html.Attributes exposing (style)
import Browser
import Browser.Events as Events
import Browser.Navigation as Navigation
import Browser.Dom as Dom exposing (Viewport, getViewport)
import Url
import Task
import Array as Array
import Debug exposing (log)

import Msg.Patchbae exposing (Msg(..))
import Models.Patchbae exposing (Model, initPatch)
import Models.Style exposing (Size)
import Views.Patchbae as PBV

type alias Flags =
  {}

main : Program Flags Model Msg
main =
    Browser.application
      { init = init
      , view = view
      , update = update
      , subscriptions = subscriptions
      , onUrlRequest = UrlRequested
      , onUrlChange = UrlChanged
      }

init : Flags -> Url.Url -> Navigation.Key -> (Model, Cmd Msg)
init flags url key =
  let 
    -- we're about to get the real size
    size = Nothing
    model = Model key size [initPatch]
  in
    ( model
    -- TODO: does this cause model / url parsing to happen twice?
    , getViewportSize
    )

-- set model/url THEN size when we get it
-- see https://package.elm-lang.org/packages/elm/core/latest/Task#Task
-- see https://discourse.elm-lang.org/t/chaining-initialisation-commands/2336
-- see https://blog.revathskumar.com/2018/11/elm-send-command-on-init.html
getViewportSize : Cmd Msg
getViewportSize =
  Dom.getViewport
  |> Task.map 
    (\{viewport} -> 
      Initialize <| Size (round viewport.width) (round viewport.height)
    )
  |> Task.perform identity

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of

    UrlRequested urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model, Navigation.pushUrl model.key (Url.toString url) )

        Browser.External href ->
          ( model, Navigation.load href )

    UrlChanged url ->
        ( model
        , Cmd.none
        )
    
    -- TODO: Portfolio Evaluator View should handle these

    Initialize size ->
      ( {model | size = Just size}
      , Cmd.none
      )

    SetSize size ->
      ( {model | size = Just size}
      , Cmd.none
      )

    SetPatchInstrument patch instrument ->
      let
        patches1 = model.patches
          |> List.map (\p -> 
            if p.id == patch.id then
              {p | instrument = instrument}
            else 
              p
          )
      in 
        ( {model | patches = patches1}
        , Cmd.none
        )
      
    SetPatchCategory patch category ->
      let
        patches1 = model.patches
          |> List.map (\p -> 
            if p.id == patch.id then
              {p | category = category}
            else 
              p
          )
      in 
        ( {model | patches = patches1}
        , Cmd.none
        )
    
    SetPatchAddress patch address ->
      let
        patches1 = model.patches
          |> List.map (\p -> 
            if p.id == patch.id then
              {p | address = address}
            else 
              p
          )
      in 
        ( {model | patches = patches1}
        , Cmd.none
        )
    
    SetPatchName patch name ->
      let
        patches1 = model.patches
          |> List.map (\p -> 
            if p.id == patch.id then
              {p | name = name}
            else 
              p
          )
      in 
        ( {model | patches = patches1}
        , Cmd.none
        )
    
    AddPatch ->
      let
        patches1 = 
          List.reverse (initPatch :: model.patches)

      in
        ( {model | patches = patches1}
        , Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch <|
  [ Events.onResize (\w h -> SetSize <| Size w h)
  ]

-- view : Model -> Browser.Document Msg
view {size, patches} =
  { title = ""
  , body = 
    [ div 
      [ style "background-color" "#000000" 
      , style "overflow" "auto"
      ] 
      [ PBV.view size patches
      ]
    ]
  }