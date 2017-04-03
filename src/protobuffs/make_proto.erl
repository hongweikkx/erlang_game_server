%%%-------------------------------------------------------------------
%%% @author gaohongwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%     生成相应的proto文件和结构
%%% @end
%%% Created : 19. 三月 2017 下午5:34
%%%-------------------------------------------------------------------
-module(make_proto).
-author("gaohongwei").
-define(PROTO_DIR, "/../proto").
-define(OUTPUT_DIR_OPTION,
    [{output_include_dir,  lists:concat([Path, "/../include"])},
        {output_src_dir, lists:concat([Path, "/../src"])},
        {output_ebin_dir, lists:concat([Path, "/../ebin"])}]).
%% API
-export([start/0]).

start() ->
    case file:get_cwd() of
    {ok, Path} ->
        ProtoDir = lists:concat([Path, ?PROTO_DIR]),
        case file:list_dir(ProtoDir) of
        {ok, FileNames} ->
            FCreate =
                fun(FileName) ->
                case string:tokens(FileName, ".") of
                [_, "proto"] ->
                    %% 是我们定义的proto文件
                    io:format("###proto:~p is create.~n", [FileName]),
                    protobuffs_compile:scan_file(FileName, ?OUTPUT_DIR_OPTION),
                    protobuffs_compile:generate_source(FileName, ?OUTPUT_DIR_OPTION),
                    io:format("###proto:~p is stop.~n", [FileName]),
                    ok;
                _R ->
                    skip
                end
                end,
            lists:foreach(FCreate, FileNames),
            ok;
        _Error ->
            io:format("###file:list_dir(~p) error:~p~n", [ProtoDir, _Error]),
            exit(_Error)
        end;
    _Error ->
        io:format("###file:get_cwd() error:~p~n", [_Error]),
        exit(_Error)
    end.


