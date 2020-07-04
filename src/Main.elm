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
import Json.Decode as D 

import Msg.PatchMsg exposing (Msg(..))
import Models.Patchbae exposing (UserData, UID, Model, userDataDecoder, initPatch, initPatches, Patches, sortBy, mostRecentIDInt, UserState(..))
import Models.Txt as Txt
import Models.Style exposing (Size)
import Views.LoginView as LoginView
import Views.PatchesView as PatchesView

type alias Flags = 
  { uid : UID
  , patches : Models.Patchbae.Patches
  , size : Size
  }

port authenticate : (String, String) -> Cmd msg
port handle_authentication : (String -> msg) -> Sub msg

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
    usr = case uid of
      Nothing -> LoggedOut "" ""
      Just "anonymous" -> Guest
      Just who -> LoggedIn who
    patches1 = if Array.length patches == 0 then initPatches else patches
  in 
    ( Model InfiniteList.init key size usr patches1
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
    
    -- LOGIN

    SetLogin str ->
      let
        user1 = case model.user of
          LoggedOut _ password -> LoggedOut str password
          FailedLogIn _ password error -> FailedLogIn str password error
          other -> other
      in 
        ( {model | user = user1}
        , Cmd.none
        )
    
    SetPassword str ->
      let
        user1 = case model.user of
          LoggedOut username _ -> LoggedOut username str
          FailedLogIn username _ error -> FailedLogIn username str error
          other -> other
      in 
        ( {model | user = user1}
        , Cmd.none
        )
    
    LogIn ->
      let
        cmd = case model.user of
          LoggedOut username password -> authenticate (username, password)
          FailedLogIn username password _ -> authenticate (username, password)
          _ -> Cmd.none
      in
        ( {model | user = LoggingIn}
        , cmd
        )
    
    SkipLogin ->
      setCache {model | user = Guest}
    
    HandleAuthentication serialized ->
      let
        failure = 
          case model.user of
            LoggedOut username password -> {model | user = FailedLogIn username password serialized}
            FailedLogIn username password error -> {model | user = FailedLogIn username password error}
            _ -> {model | user = FailedLogIn "" "" serialized}
        model1 = 
          case D.decodeString userDataDecoder serialized of
            Ok res -> 
              case res.uid of
                Just who -> {model | user = LoggedIn who, patches = res.patches}
                _ -> failure
            err -> 
              let _ = log "Error parsing user patches:" err
              in failure
      in
        ( model1
        , Cmd.none
        )
    
    -- HEADER

    LogOut ->
      setCache {model | user = LoggedOut "" "", patches = initPatches}

    -- PATCHES

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
  let
    uid = case model.user of
      LoggedIn who -> Just who
      Guest -> Just "anonymous"
      _ -> Nothing
  in
    ( model 
    , save <| UserData uid model.patches
    )

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch <|
  [ Events.onResize (\w h -> SetSize <| Size w h)
  , handle_authentication HandleAuthentication
  ]

view : Model -> Browser.Document Msg
view model =
  let 
    cv = case model.user of
      LoggedOut _ _ -> LoginView.view model
      LoggingIn -> LoginView.view model
      FailedLogIn _ _ _ -> LoginView.view model
      _ -> PatchesView.view model
  in 
    { title = Txt.title
    , body =
      [ cv
      ]
    }