port module Main exposing (init, update)

import Html exposing (..)
import Html.Attributes exposing (style)
import Browser
import Browser.Events as Events
import Browser.Navigation as Navigation
import Browser.Dom as Dom exposing (Viewport, getViewport)
import Url
import Task
import Array as Array
import Array.Extra as A
import InfiniteList
import Debug exposing (log)

import Msg.PatchMsg exposing (Msg(..))
import Models.Patchbae exposing (Model, initPatch, Patches, sortBy, mostRecentIDInt)
import Models.Txt as Txt
import Models.Style exposing (Size)
import Views.PatchView as PBV

type alias Flags =
  {}

-- Elm requests historic performance data
port cached : Patches -> Cmd msg

-- save.js provides historic performance data
port receive : (Patches -> msg) -> Sub msg

-- Elm wants to save the model
port save : Patches -> Cmd msg

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
    model = Model InfiniteList.init key Nothing [initPatch]
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
      -- Load user data on init 
      , cached <| model.patches
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
        , save patches1
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
        , save patches1
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
        , save patches1
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
        , save patches1
        )
    
    AddPatch ->
      let
        lastID = mostRecentIDInt model.patches
        newID = String.fromInt <| lastID + 1
        newPatch = {initPatch | id = newID}
        -- Add an initialized element at the beginning of the list of all patches
        patches1 = 
          newPatch :: model.patches

      in
        ( {model | patches = patches1}
        , save patches1
        )
    
    RmPatch patch ->
      let
        patches1 = List.filter (\{id} -> id /= patch.id) model.patches

      in
        ( {model | patches = patches1}
        , save patches1
        )
    
    SetPatchRating patch rating ->
      let
        patches1 = model.patches
          |> List.map (\p -> 
            if p.id == patch.id then
              {p | rating = rating}
            else 
              p
          )
      in 
        ( {model | patches = patches1}
        , save patches1
        )
    
    -- Load user's patches
    ReceivePatches patches ->
      let
        patches1 = case patches of
            [] -> [initPatch]
            _ -> patches
      in ( {model | patches = patches1}
      , Cmd.none
      )
    
    SortBy how ->
      let
        patches1 = sortBy model.patches how
      in ( {model | patches = patches1}
      , save patches1 -- why not remember the sort?
      )
    
    InfiniteListMsg infiniteList ->
      ( { model | infiniteList = infiniteList }
      , Cmd.none 
      )

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch <|
  [ Events.onResize (\w h -> SetSize <| Size w h)
  , receive ReceivePatches
  ]

-- view : Model -> Browser.Document Msg
view model =
  { title = Txt.title
  , body = 
    [ div 
      [ style "background-color" "#1d1d1d" 
      , style "height" "100%"
      ] 
      [ PBV.view model
      ]
    ]
  }