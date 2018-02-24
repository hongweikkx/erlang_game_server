%%%-------------------------------------------------------------------
%%% @author gaohongwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%     game 服务器启动和关闭相关
%%% @end
%%% Created : 04. 四月 2017 下午11:04
%%%-------------------------------------------------------------------
-module(game_server).
-include("common.hrl").
-define(APPS, [crypto, lager, emysql, ranch_tcp]).


%% API
-export([
    start/0,
    stop/0
]).

start() ->
    ensure_start(?APPS).


ensure_start([App | Tail]) ->
    case application:ensure_all_started(App) of
        {ok, _} ->
            ensure_start(Tail);
        {error, Reason} ->
            lager:error("start app:~p error, reason:~p ~n", [App, Reason]),
            ok
    end.

stop() ->
    stop(lists:reverse(?APPS)),
    ok.

stop([App | Tail]) ->
    application:stop(App),
    stop(Tail).
