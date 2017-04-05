%%%-------------------------------------------------------------------
%%% @author gaohongwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%      数据库启动 关闭相关
%%% @end
%%% Created : 04. 四月 2017 下午11:03
%%%-------------------------------------------------------------------
-module(db_agent).
-author("gaohongwei").

%% API
-export([
    start/0,
    stop/0
]).

start() ->
    %% todo 把一些东西都写到配置里面
    DBList = [k_game_db, k_log_db],
    [start_db(DbId) || DbId <- DBList],
    ok.

start_db(Id) ->
    Host = "127.0.0.1",
    User = "gaohongwei",
    Password = "rsrzrcj",
    Post = 3306,
    Database = "k_game_db",
    ConnectNums = 5,
    p1_mysql:start_link(Id, Host, Post, User, Password, Database),
    [p1_mysql:connect(Id, Host, Post, User, Password, Database, true) || _Num <- lists:seq(1, ConnectNums)],
    ok.

stop() ->
    p1_mysql:stop().



