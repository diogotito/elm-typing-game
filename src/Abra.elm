module Abra exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Array exposing (Array)
import Browser
import Browser.Dom
import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random
import Task
import Time



-- Config


texts : Random.Generator ( String, String )
texts =
    Random.uniform
        ( "The quick brown fox jumps over the lazy dog", "I don't know" )
        [ ( "Grumpy wizards make toxic brew for the evil queen and jack.", "Who knows" )
        , ( "Some painters transform the sun into a yellow spot, others transform a yellow spot into the sun.", "Pablo Diego José Francisco de Paula Juan Nepomuceno María de los Remedios Cipriano de la Santísima Trinidad Ruiz y Picasso" )
        , ( "What you guys are referring to as Linux, is in fact, GNU/Linux, or as I've recently taken to calling it, GNU plus Linux.", "Richard Stallman" )
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
    , author : String
    , position : Int
    , lastKey : Maybe Char
    , playerMadeMistake : Bool
    , errors : Int
    , time : Int
    }


currentLetter : Model -> Maybe Char
currentLetter { sentence, position } =
    Array.get position sentence


sentenceFinished : Model -> Bool
sentenceFinished { lastKey, sentence, position } =
    lastKey /= Nothing && position == Array.length sentence


init : () -> ( Model, Cmd Msg )
init _ =
    ( { sentence = Array.empty
      , author = ""
      , position = 0
      , lastKey = Nothing
      , playerMadeMistake = False
      , errors = 0
      , time = 0
      }
    , Random.generate NewText texts
    )



-- Update


type Msg
    = Input String
    | Restart
    | NewText ( String, String )
    | Tick Time.Posix
    | Focused (Result Browser.Dom.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input text ->
            let
                key =
                    List.head (String.toList text)

                new_model =
                    if key == currentLetter model then
                        { model
                            | position = model.position + 1
                            , playerMadeMistake = False
                            , lastKey = key
                        }

                    else
                        { model
                            | playerMadeMistake = True
                            , errors = model.errors + 1
                            , lastKey = key
                        }

                cmd =
                    if sentenceFinished new_model then
                        Task.attempt Focused <| Browser.Dom.focus "restart-button"

                    else if key == Just '\\' then
                        Task.perform (\_ -> Restart) (Task.succeed ())

                    else
                        Cmd.none
            in
            ( new_model, cmd )

        Tick _ ->
            ( { model | time = model.time + 1 }, Cmd.none )

        Restart ->
            init ()

        NewText ( sentence, author ) ->
            ( { model
                | sentence = sentence |> String.toList |> {- List.take 10 |> -} Array.fromList
                , author = author
              }
            , Task.attempt Focused <| Browser.Dom.focus "player-input"
            )

        Focused result ->
            Debug.log (Debug.toString result) ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.lastKey /= Nothing && not (sentenceFinished model) then
        Time.every 1000 Tick

    else
        Sub.none



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
        , div
            [ classList
                [ ( "author-wrapper", True )
                , ( "revealed", sentenceFinished model )
                ]
            ]
            [ div [ class "author" ] [ text model.author ] ]
        , playerInput model
        , div [ class "status" ]
            [ div []
                [ text <|
                    case model.errors of
                        0 ->
                            "No typos!"

                        1 ->
                            "1 typo"

                        n ->
                            String.fromInt n ++ " typos"
                ]
            , div []
                [ text "Time: "
                , span
                    [ classList
                        [ ( "stopwatch", True )
                        , ( "disabled", model.lastKey == Nothing || sentenceFinished model )
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
            , attribute "autocapitalize" "none"
            , attribute "autocorrect" "off"
            , autocomplete False
            , spellcheck False
            , value ""
            , id "player-input"
            ]
            []

    else
        button [ id "restart-button", onClick Restart ] [ text "Restart" ]


letters : Model -> List (Html Msg)
letters model =
    Array.toList model.sentence
        |> List.indexedMap
            (\i c ->
                span
                    [ classList
                        [ ( "letter", True )
                        , ( "highlighted", i == model.position )
                        , ( "cleared", i < model.position )
                        , ( "space", c == ' ' )
                        ]
                    ]
                    [ text (String.fromChar c) ]
            )
