module Billing exposing(..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Navigation as Nav
import Task



main =
  Nav.program (Nav.makeParser .username)
    { init = init
    , subscriptions = subscriptions
    , update = update
    , urlUpdate = urlUpdate
    , view = view
    }



-- MODEL


type alias Model =
  { empty: Maybe Int
  }


init : data -> (Model, Cmd Msg)
init _ =
  ( Model Nothing
  , Cmd.none
  )


baseUrl : String
baseUrl =
    "http://localhost:4000"

loginUrl : String
loginUrl =
    baseUrl ++ "/auth/login"

accessCalendarUrl : String
accessCalendarUrl =
    baseUrl ++ "/auth/calendar"

offlineAccessUrl : String
offlineAccessUrl =
    baseUrl ++ "/auth/offline"

logoutUrl : String
logoutUrl =
    baseUrl ++ "/auth/logout"



-- UPDATE


type Msg
  = NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    NoOp ->
      ( model
      , Cmd.none
      )



-- URL UPDATE


urlUpdate : data -> model -> (model, Cmd msg)
urlUpdate data model =
    ( model
    , Cmd.none
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ a [ href loginUrl ] [ text "Sign in or create an account through Google; " ]
    , a [ href accessCalendarUrl ] [ text "Authorize calendar access; " ]
    , a [ href offlineAccessUrl ] [ text "Authorize offline access; " ]
    , a [ href logoutUrl ] [ text "Logout" ]
    ]



-- HTTP





{-
getRandomGif : String -> Cmd Msg
getRandomGif topic =
  let
    url =
      "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeGifUrl url)


decodeGifUrl : Json.Decoder String
decodeGifUrl =
  Json.at ["data", "image_url"] Json.string
-}
