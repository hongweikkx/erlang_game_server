%%%-------------------------------------------------------------------
%%% @author gaohongwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%      从db t_users 表中获取数据
%%% @end
%%% Created : 03. 四月 2017 下午6:13
%%%-------------------------------------------------------------------
-module(db_agent_user).
-author("gaohongwei").
-define(T_USERS, t_users).

%% API
-export([get_role_list/3]).

%% todo
get_role_list(_ServerId, _PlatformId, _Suid) ->
    [].

