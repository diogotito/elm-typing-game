# elm-typing-game
A barebones touch typing test written in [Elm](https://elm-lang.org/).

Available at https://diogotito.github.io/elm-typing-game/


Development
----------------
To build this app, you'll need to have [Elm installed](https://guide.elm-lang.org/install/elm.html). Then:

```sh
git clone https://github.com/diogotito/elm-typing-game.git
cd elm-typing-game
elm make src/Abra.elm --output dist/index.js
```

If you want to play with this code but hate reloading your browser, you can use the `dev-server.bash` script
in this repo.

```
./dev-server.bash
```

It uses
[Bash](https://www.gnu.org/software/bash/),
[entr](http://eradman.com/entrproject/) and
[elm-live](https://www.elm-live.com/),
so you need to have those available in your `$PATH` before you can run it.
The page served on http://localhost:8000 refreshes each time you save changes in any
.html, .css and .elm file while this script is running.
