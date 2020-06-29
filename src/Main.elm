port module Main exposing (init, update)

import Html exposing (..)
import Html.Attributes as A exposing (style)
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
import Models.Patchbae exposing (UserData, UID, Model, initPatch, initPatches, Patches, sortBy, mostRecentIDInt)
import Models.Txt as Txt
import Models.Style exposing (Size)
import Views.PatchView as PBV

type alias Flags = 
  { uid : UID
  , patches : Models.Patchbae.Patches
  , size : Size
  }

-- Elm wants to save the model
port save : UserData -> Cmd msg

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
init {uid, patches, size} url key =
  let
      patches1 = if Array.length patches == 0 then initPatches else patches
  in 
    ( Model InfiniteList.init key size uid patches1
    , Cmd.none
    )

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

    SetSize size ->
      ( {model | size = size}
      , Cmd.none
      )

    SetPatchInstrument patch instrument ->
      let
        patches1 = model.patches
          |> Array.map (\p -> 
            if p.id == patch.id then
              {p | instrument = instrument}
            else 
              p
          )
      in 
        setCache {model | patches = patches1}
      
    SetPatchCategory patch category ->
      let
        patches1 = model.patches
          |> Array.map (\p -> 
            if p.id == patch.id then
              {p | category = category}
            else 
              p
          )
      in 
        setCache {model | patches = patches1}
    
    SetPatchAddress patch address ->
      let
        patches1 = model.patches
          |> Array.map (\p -> 
            if p.id == patch.id then
              {p | address = address}
            else 
              p
          )
      in 
        setCache {model | patches = patches1}
    
    SetPatchName patch name ->
      let
        patches1 = model.patches
          |> Array.map (\p -> 
            if p.id == patch.id then
              {p | name = name}
            else 
              p
          )
      in 
        setCache {model | patches = patches1}
    
    AddPatch ->
      let
        lastID = mostRecentIDInt model.patches
        newID = String.fromInt <| lastID + 1
        newPatch = {initPatch | id = newID}
        -- Add an initialized element at the beginning of the list of all patches
        patches1 = 
          Array.append (Array.fromList [newPatch]) model.patches

      in
        setCache {model | patches = patches1}
    
    RmPatch patch ->
      let
        patches1 = Array.filter (\{id} -> id /= patch.id) model.patches

      in
        setCache {model | patches = patches1}
    
    SetPatchRating patch rating ->
      let
        patches1 = model.patches
          |> Array.map (\p -> 
            if p.id == patch.id then
              {p | rating = rating}
            else 
              p
          )
      in 
        setCache {model | patches = patches1}
    
    SortBy how ->
      let patches1 = sortBy model.patches how
      in setCache {model | patches = patches1}
    
    InfiniteListMsg infiniteList ->
      ( { model | infiniteList = infiniteList }
      , Cmd.none 
      )

setCache : Model -> (Model, Cmd msg)
setCache model =
  ( model 
  , save <| UserData model.uid model.patches
  )

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch <|
  [ Events.onResize (\w h -> SetSize <| Size w h)
  ]

-- view : Model -> Browser.Document Msg
view model =
  { title = Txt.title
  , body = 
    [ PBV.view model
    ]
  }