%%%-------------------------------------------------------------------
%%% @author gaohongwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%     game 服务器启动和关闭相关
%%% @end
%%% Created : 04. 四月 2017 下午11:04
%%%-------------------------------------------------------------------
-module(game_server).
-author("gaohongwei").

%% API
-export([
    start/0,
    stop/0
]).

start() ->
    %% todo 服务器公共进程的开启
    %% 开启客户端接收进程
    start_client().

start_client() ->
    io:format("##### start client.~n"),
    tcp_server_sup:start_link().

stop() ->
    %% todo 服务器公共进程的关闭
    ok.
