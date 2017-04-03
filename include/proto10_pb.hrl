-ifndef(CS_10000_PB_H).
-define(CS_10000_PB_H, true).
-record(cs_10000, {
    server_id = erlang:error({required, server_id}),
    platform_id = erlang:error({required, platform_id}),
    platform = erlang:error({required, platform}),
    suid = erlang:error({required, suid})
}).
-endif.

-ifndef(ROLE_INFO_PB_H).
-define(ROLE_INFO_PB_H, true).
-record(role_info, {
    nick_name = erlang:error({required, nick_name}),
    sex = erlang:error({required, sex}),
    career = erlang:error({required, career})
}).
-endif.

-ifndef(SC_10000_PB_H).
-define(SC_10000_PB_H, true).
-record(sc_10000, {
    ret = erlang:error({required, ret}),
    role_list = []
}).
-endif.

-ifndef(CS_10001_PB_H).
-define(CS_10001_PB_H, true).
-record(cs_10001, {
    role = erlang:error({required, role})
}).
-endif.

-ifndef(SC_10001_PB_H).
-define(SC_10001_PB_H, true).
-record(sc_10001, {
    ret = erlang:error({required, ret}),
    role = erlang:error({required, role})
}).
-endif.

-ifndef(CS_10002_PB_H).
-define(CS_10002_PB_H, true).
-record(cs_10002, {
    server_id = erlang:error({required, server_id}),
    platform_id = erlang:error({required, platform_id}),
    platform = erlang:error({required, platform}),
    suid = erlang:error({required, suid}),
    nick_name = erlang:error({required, nick_name}),
    sex = erlang:error({required, sex}),
    career = erlang:error({required, career})
}).
-endif.

-ifndef(SC_10002_PB_H).
-define(SC_10002_PB_H, true).
-record(sc_10002, {
    ret = erlang:error({required, ret})
}).
-endif.

