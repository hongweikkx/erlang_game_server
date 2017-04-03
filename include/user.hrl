%%%-------------------------------------------------------------------
%%% @author gaohongwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%      玩家头文件模块
%%% @end
%%% Created : 11. 三月 2017 下午9:06
%%%-------------------------------------------------------------------
-ifndef(USER_HRL).
-define(USER_HRL, true).

-define(CLIENT_STATE_UNLOGIN,      0).    %% 玩家没有登陆
-define(CLIENT_STATE_LOGIN,        1).    %% 玩家已经登陆
-define(CLIENT_STATE_LOGIC,        2).    %% 玩家已经进入到逻辑中

-define(MALE,                  1).    %% 男性
-define(FEMALE,                2).    %% 女性

-define(CLIENT_ROLE_SUC,         0).
-define(CLIENT_ROLE_ERROR_CLIENT_ARG_ERROR, 1). %% 前端传过来的参数是错误的
-define(CLIENT_ROLE_ERROR_HAD_THE_ROLE,   2).   %% 已经有这个角色了
-define(CLIENT_ROLE_STATE_IN_LOGIC,       3).   %% 玩家已经进入角色处理了
-define(CLIENT_ROLE_STATE_IN_LOGIN,       4).   %% 玩家已经登陆


-record(client_state, {sock,
    state = ?CLIENT_STATE_UNLOGIN,
    recv_ref,
    user_pid,
    serverId,    %% 服务器id
    platform,    %% 平台
    platformId,  %% 平台id
    suid         %% 平台账号
}).


-endif.
