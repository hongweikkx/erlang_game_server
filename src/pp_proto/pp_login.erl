%%%-------------------------------------------------------------------
%%% @author gaohongwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%     login
%%%     doc: 现在是单服务器的架构
%%% @end
%%% Created : 15. 三月 2017 上午12:09
%%%-------------------------------------------------------------------
-module(pp_login).
-include("user.hrl").
-include("proto10_pb.hrl").

%% API
-export([
    get_rolelist/2,
    create_role/2,
    login_role/2
]).

%% todo
%% return: #client_state{}
%% process: client
get_rolelist(ClientState, {ServerId, PlatformId, _Platform, Suid}) ->
    %% todo 从db中拿到role_list
    RoleList = db_agent_user:get_role_list(ServerId, PlatformId, Suid),
    %% todo 映射role_list到可发送到list
    NRoleList = map_role_list_to_send(RoleList),
    {ok, Bin} = proto10:write(10000, {0, NRoleList}),
    %%todo 发送给客户端
    lib_send:send_to_user(ClientState, Bin),
    ClientState.

%% todo
%% return: #client_state{}
%% process: client
create_role(ClientState, {RoleInfo}) ->
    case check_can_create_role(ClientState, RoleInfo) of
        ok ->
            {ok, NClientState} = create_role_util(ClientState, RoleInfo),
            {ok, Bin} = proto10:write(10001, {?CLIENT_ROLE_SUC, RoleInfo}),
            lib_send:send_to_user(ClientState, Bin),
            NClientState;
        {error, ErrorCode} ->
            {ok, Bin} = proto10:write(10001, {ErrorCode, RoleInfo}),
            lib_send:send_to_user(ClientState, Bin),
            ClientState
    end.

create_role_util(ClientState, _RoleInfo) ->
    %% todo
    %% 建立一个初始化的 t_users, 然后写入db
    ClientState.

%% todo
%% return: #client_state{}
%% process: client
login_role(ClientState, {ServerId, PlatformId, _Platform, Suid, NickName, Sex, Career}) ->
    case check_can_login_role(ServerId, PlatformId, Suid, NickName, Sex, Career) of
        {ok, _UserStatus} ->
            %% todo 更新 clientState
            %% todo 创建一个进程
            {ok, Bin} = proto10:write(10001, {?CLIENT_ROLE_SUC}),
            lib_send:send_to_user(ClientState, Bin);
        {error, ErrorCode} ->
            {ok, Bin} = proto10:write(10002, {ErrorCode}),
            lib_send:send_to_user(ClientState, Bin)
    end.

%% 检查是否可以创建当前到角色
check_can_create_role(ClientState, RoleInfo) ->
    #client_state{state = State, platformId = PlatformId, suid = Suid, serverId = ServerId} = ClientState,
    #role_info{nick_name = NickName, career = Career, sex = Sex} = RoleInfo,
    RoleList = db_agent_user:get_role_list(ServerId, PlatformId, Suid),
    case is_roleinfo_normal(NickName, Career, Sex) of
        true ->
            %%角色信息正常
            case is_have_the_role(Career, Sex, RoleList) of
                false ->
                    %% 没有这个角色存在
                    check_client_state_normal_when_create(State);
                true ->
                    {error, ?CLIENT_ROLE_ERROR_HAD_THE_ROLE}
            end;
        false ->
            {error, ?CLIENT_ROLE_ERROR_CLIENT_ARG_ERROR}
    end.

check_client_state_normal_when_create(State) ->
    if
        State =:= ?CLIENT_STATE_UNLOGIN ->
            ok;
        State =:= ?CLIENT_STATE_LOGIC ->
            {error, ?CLIENT_STATE_LOGIC};
        State =:= ?CLIENT_STATE_LOGIN ->
            {error, ?CLIENT_ROLE_STATE_IN_LOGIN}
    end.

%% todo
check_can_login_role(_ServerId, _PlatformId, _Suid, _NickName, _Sex, _Career) ->
    ok.

%% 是否角色信息满足角色的原型设定
is_roleinfo_normal(NickName, Career, Sex) ->
    IsNickName = is_list(NickName),   %%其实不需要测试这个 只是后来加需求方便而已
    IsCareer = is_integer(Career),    %% 其实不需要测试这个
    IsSex = (Sex =:= ?MALE orelse Sex =:= ?FEMALE),
    IsNickName andalso IsCareer andalso IsSex.

is_have_the_role(Career, Sex, RoleList) ->
    FAny = fun(#role_info{career = RoleCareer, sex = RoleSex}) ->
        RoleCareer =:= Career andalso RoleSex =:= Sex end,
    lists:any(FAny, RoleList).

%% todo
map_role_list_to_send(_RoleList) ->
    [].

