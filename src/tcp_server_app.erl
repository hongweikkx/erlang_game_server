-module(tcp_server_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_, _) ->
    io:format("## hello world!!!~n"),
    %% logger
    LagerRet = lager:start(),
    io:format("### lager start ret:~p~n", [LagerRet]),
    %% db
    DbAgentRet = db_agent:start(),
    io:format("### db_agent start ret:~p~n", [DbAgentRet]),
    %% game_server
    GameServerRet = game_server:start(),
    io:format("### game_server start ret:~p~n", [GameServerRet]),
    ok.

stop(_State) ->
    game_server:stop(),
    db_agent:stop(),
    io:format("## by world!!!~n"),
    ok.
