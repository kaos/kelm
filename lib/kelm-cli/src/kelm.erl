%% Copyright 2014 Andreas Stenius
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(kelm).
-export([main/1]).


%%% --------------------------------------------------------------------------------
%%% API
%%% --------------------------------------------------------------------------------

main([]) ->
    usage();

main(Args) ->
    {ok, {Opts, Cmds}} = parse_opts(Args),
    fmt("opts: ~p~n", [Opts]),
    run(Cmds, Opts).


%%% --------------------------------------------------------------------------------
%%% Internals
%%% --------------------------------------------------------------------------------

usage() ->
    getopt:usage(opt_spec(), "kelm", "[command ...]",
                 [{"command", "Commands to execute. "
                   "See 'help commands' for available commands."}
                 ]).

parse_opts(Args) ->
    getopt:parse(opt_spec(), Args).
    
run([], _Opts) -> ok;
run(Cmds, Opts) ->
    case catch exec(Cmds, Opts) of
        {ok, Cmds1, Opts1} -> run(Cmds1, Opts1);
        {error, Message} ->
            fmt_err("kelm: ~s~n", [Message])
    end.

exec(["help"], Opts) ->
    exec(["help", "help"], Opts);

exec(["help"|Cmds], Opts) ->
    [help(Cmd) || Cmd <- Cmds],
    {ok, [], Opts};

exec(["init"|Cmds], Opts) ->
    init_manifest(Cmds, Opts);

exec(["publish"|Cmds], Opts) ->
    fmt_err("NYI\n"),
    {ok, Cmds, Opts};

exec([Cmd|_], _Opts) ->
    {error, ["unknown command: ", Cmd]}.

init_manifest(Cmds, Opts) ->
    {Dir, Cmds1} = get_dir(Cmds),
    AppDir = filename:join([Dir, "ebin"]),
    Manifest = [get_name(Dir), ".manifest"],
    case filelib:wildcard([AppDir, "/*.app"]) of
        [] -> {error, ["missing library .app file in ", AppDir]};
        [App] ->
            fmt("Manifest: ~s~n", [Manifest]),
            fmt("App file: ~s~n", [App]),
            {ok, Cmds1, Opts};
        _ ->
            {error, ["too many .app files in ", AppDir]}
    end.

get_dir([]) -> {".", []};
get_dir([D|Cmds1]=Cmds0) ->
    case filelib:is_dir(D) of
        true -> {D, Cmds1};
        false -> {".", Cmds0}
    end.

get_name(Dir) ->
    case filename:basename(Dir) of
        "." -> "kelm";
        Name -> Name
    end.

help("commands") ->
    fmt_err("Available commands:\n\n~s\n",
        [string:join(["init","help","publish"], ", ")]);

help("help") ->
    fmt_err("Usage: kelm help [command ...]\n\n"
        "Get help on commands.\n");

help("init") ->
    fmt_err("Usage: kelm init [library]\n\n"
            "Initialize a new kelm.manifest file for library in "
            "the current directory.\n");

help("publish") ->
    fmt_err("Usage: kelm publish [manifest]\n\n"
        "Publish library as detailed in the manifest.\n"
        "If no manifest is specified, it defaults to kelm.manifest.\n");

help(Cmd) ->
    fmt_err("help: no help on '~s'\n", [Cmd]).


opt_spec() ->
    [{global, $g, "global", {boolean, false}, desc(global)}
    ].

desc(global) ->
    io_lib:format("Use global lib dir (~s)", [code:lib_dir()]).

fmt(Msg) -> fmt("~s", [Msg]).
fmt(Fmt, Args) ->
    io:format(Fmt, Args).

fmt_err(Msg) -> fmt_err("~s", [Msg]).
fmt_err(Fmt, Args) ->
    io:format(standard_error, Fmt, Args).
