%%%-------------------------------------------------------------------
%%% @author gaohongwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%     解析前端传过来的proto文件
%%% @end
%%% Created : 26. 三月 2017 下午6:51
%%%-------------------------------------------------------------------
-module(proto10).
-include("proto10_pb.hrl").

%% API
-export([read/2,
    write/2]).

read(10000, Data) ->
    #cs_10000{server_id = ServerId, platform = Platform, platform_id = PlatId, suid = Suid}
        = proto10_pb:decode(cs_10000, Data),
    {ok, {ServerId, PlatId, Platform, Suid}};

read(10001, Data) ->
    #cs_10001{role = Role} = proto10_pb:decode(cs_10001, Data),
    {ok, {Role}};
read(10002, Data) ->
    #cs_10002{server_id = ServerId, platform_id = PlatformId, platform = Platform,
         suid = Suid, nick_name = NickName, sex = Sex, career = Career} = proto10_pb:decode(cs_10002, Data),
    {ok, {ServerId, PlatformId, Platform, Suid, NickName, Sex, Career}};

read(Cmd, Data) ->
    %% todo 加入log系统
    io:format("####read Cmd:~p is not matching, data:~p~n", [Cmd, Data]),
    error.

write(10000, {Ret, RoleList}) ->
    R = #sc_10000{ret = Ret, role_list = RoleList},
    B = proto10_pb:encode(R),
    {ok, B};
write(10001, {Ret}) ->
    R = #sc_10001{ret = Ret},
    B = proto10_pb:encode(R),
    {ok, B};
write(10002, {Ret}) ->
    R = #sc_10002{ret = Ret},
    B = proto10_pb:encode(R),
    {ok, B};

write(Cmd, Data) ->
    io:format("###write Cmd:~p is not matching, data:~p~n", [Cmd, Data]),
    error.
