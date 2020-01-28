module Abra exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Array exposing (Array)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random
import Time



-- Config


texts : Random.Generator String
texts =
    Random.uniform
        "The quick brown fox jumps over the lazy dog"
        [ "Grumpy wizards make toxic brew for the evil queen and jack."
        , "Some painters transform the sun into a yellow spot, others transform a yellow spot into the sun."
        , "What you guys are referring to as Linux, is in fact, GNU/Linux, or as I've recently taken to calling it, GNU plus Linux.\n"
        ]



--


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--


type alias Model =
    { sentence : Array Char
    , position : Int
    , lastKey : Maybe Char
    , playerMadeMistake : Bool
    , errors : Int
    , time : Int
    }


currentLetter : Model -> Char
currentLetter { sentence, position } =
    Maybe.withDefault '?' <| Array.get position sentence


sentenceFinished : Model -> Bool
sentenceFinished { sentence, position } =
    position == Array.length sentence


init : () -> ( Model, Cmd Msg )
init _ =
    ( { sentence = Array.empty
      , position = 0
      , lastKey = Nothing
      , playerMadeMistake = False
      , errors = 0
      , time = 0
      }
    , Random.generate NewText <| texts
    )



-- Update


type Msg
    = Input String
    | Restart
    | NewText String
    | Tick Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( update_ msg model
    , if msg == Restart then
        Tuple.second (init ())

      else
        Cmd.none
    )


update_ : Msg -> Model -> Model
update_ msg model =
    case msg of
        Input text ->
            case List.head (String.toList text) of
                Just key ->
                    if key == currentLetter model then
                        { model
                            | position = model.position + 1
                            , playerMadeMistake = False
                            , lastKey = Just key
                        }

                    else
                        { model
                            | playerMadeMistake = True
                            , errors = model.errors + 1
                            , lastKey = Just key
                        }

                Nothing ->
                    model

        Tick _ ->
            if model.lastKey /= Nothing && not (sentenceFinished model) then
                { model | time = model.time + 1 }

            else
                model

        Restart ->
            Tuple.first <| init ()

        NewText text ->
            { model | sentence = text |> String.toList |> Array.fromList }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 Tick



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "typing-game" ]
        [ h1 [] [ text "Elm typing game!!" ]
        , div
            [ classList
                [ ( "text-to-type", True )
                , ( "errorAnim", model.playerMadeMistake )
                , ( "disabled", sentenceFinished model )
                ]
            ]
            (letters model)
        , playerInput model
        , div [ class "status" ]
            [ div []
                [ text <|
                    "Number of errors: "
                        ++ String.fromInt model.errors
                ]
            , div []
                [ text "Time: "
                , span
                    [ classList
                        [ ( "stopwatch", True )
                        , ( "disabled", sentenceFinished model )
                        ]
                    ]
                    [ text <| String.fromInt model.time ]
                ]
            ]
        ]


playerInput : Model -> Html Msg
playerInput model =
    let
        placeholderText =
            let
                placeholder =
                    case model.lastKey of
                        Just ' ' ->
                            "_"

                        Just char ->
                            String.fromChar char

                        Nothing ->
                            ""
            in
            if model.playerMadeMistake then
                placeholder ++ " !!!"

            else
                placeholder
    in
    if not (sentenceFinished model) then
        input
            [ type_ "text"
            , maxlength 1
            , onInput Input
            , placeholder placeholderText
            , value ""
            , autofocus True
            ]
            []

    else
        button [ autofocus True, onClick Restart ] [ text "Restart" ]


letters : Model -> List (Html Msg)
letters model =
    Array.toList model.sentence
        |> List.indexedMap
            (\i c ->
                span
                    [ classList
                        [ ( "letter", True )
                        , ( "highlighted", i == model.position )
                        , ( "space", c == ' ' )
                        ]
                    ]
                    [ text (String.fromChar c) ]
            )
