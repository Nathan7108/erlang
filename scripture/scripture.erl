
-module(scripture).
-export([start/0]).

-define(CLEAR, "\e[H\e[2J").

start() ->
    Reference = {"Proverbs", 3, 5, 6},
    Text = "Trust in the Lord with all your heart and lean not on your own understanding.",
    Words = string:tokens(Text, " "),
    HiddenWords = lists:map(fun(W) -> {W, false} end, Words),
    loop(Reference, HiddenWords).

loop(Reference, Words) ->
    io:format(?CLEAR),
    display(Reference, Words),
    io:format("~nPress Enter to hide more words or type 'quit' to exit.~n"),
    case io:get_line("") of
        "quit\n" ->
            io:format("Goodbye!~n"),
            ok;
        _ ->
            NewWords = hide_random_words(Words),
            case all_hidden(NewWords) of
                true ->
                    io:format(?CLEAR),
                    display(Reference, NewWords),
                    io:format("~nAll words are hidden. Program finished.~n"),
                    ok;
                false ->
                    loop(Reference, NewWords)
            end
    end.

display({Book, Chapter, StartVerse, EndVerse}, Words) ->
    Reference =
        case EndVerse of
            undefined -> io_lib:format("~s ~p:~p", [Book, Chapter, StartVerse]);
            _ -> io_lib:format("~s ~p:~p-~p", [Book, Chapter, StartVerse, EndVerse])
        end,
    io:format("~s~n", [lists:flatten(Reference)]),
    lists:foreach(fun({Word, Hidden}) ->
        if
            Hidden -> io:format("~s ", [string:copies("_", length(Word))]);
            true -> io:format("~s ", [Word])
        end
    end, Words),
    io:format("~n").

hide_random_words(Words) ->
    VisibleWords = [W || W = {_, false} <- Words],
    case length(VisibleWords) of
        0 -> Words;
        _ ->
            RandomIndex = rand:uniform(length(VisibleWords)) - 1,
            {Word, _} = lists:nth(RandomIndex + 1, VisibleWords),
            lists:map(fun(W) -> if W =:= {Word, false} -> {Word, true}; true -> W end end, Words)
    end.

all_hidden(Words) ->
    lists:all(fun({_, Hidden}) -> Hidden end, Words).
