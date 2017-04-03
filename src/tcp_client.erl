%%%-------------------------------------------------------------------
%%% @author gaohongwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%      玩家协议接受进程
%%% @end
%%% Created : 11. 三月 2017 下午8:24
%%%-------------------------------------------------------------------
-module(tcp_client).
-behaviour(gen_server).

-include("user.hrl").


%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).


%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
    {ok, State :: #client_state{}} | {ok, State :: #client_state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init([Sock]) ->
    ClientState = #client_state{
        sock = Sock,
        state = ?CLIENT_STATE_UNLOGIN
    },
    {ok, ClientState, 0}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #client_state{}) ->
    {reply, Reply :: term(), NewState :: #client_state{}} |
    {reply, Reply :: term(), NewState :: #client_state{}, timeout() | hibernate} |
    {noreply, NewState :: #client_state{}} |
    {noreply, NewState :: #client_state{}, timeout() | hibernate} |
    {stop, Reason :: term(), Reply :: term(), NewState :: #client_state{}} |
    {stop, Reason :: term(), NewState :: #client_state{}}).
handle_call(_Info, _From, State) ->
    try
        do_call(_Info, _From, State)
    catch
        _:Reason  ->
            io:format("do_call info:~p wrong, the reason is:~p~n", [_Info, Reason]),
            {reply, error, State}
    end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #client_state{}) ->
    {noreply, NewState :: #client_state{}} |
    {noreply, NewState :: #client_state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #client_state{}}).
handle_cast(Info, State) ->
    try
        do_cast(Info, State)
    catch
        _:Reason  ->
            io:format("do_call info:~p wrong, the reason is:~p~n", [Info, Reason]),
            {noreply, State}
    end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
-spec(handle_info(Info :: timeout() | term(), State :: #client_state{}) ->
    {noreply, NewState :: #client_state{}} |
    {noreply, NewState :: #client_state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #client_state{}}).
handle_info(_Info, State) ->
    try
        do_info(_Info, State)
    catch
        _:Reason  ->
            io:format("do_call info:~p wrong, the reason is:~p~n", [_Info, Reason]),
            {noreply, State}
    end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
-spec(terminate(Reason :: (normal | shutdown | {shutdown, term()} | term()),
    State :: #client_state{}) -> term()).
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #client_state{},
    Extra :: term()) ->
    {ok, NewState :: #client_state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
do_call(_Info, _From, ClientState) ->
    io:format("#### do_call msg:~p is undefined.~n", [_Info]),
    {reply, error, ClientState}.

do_cast(_Info, ClientState) ->
    io:format("#### do_cast msg:~p is undefined.~n", [_Info]),
    {noreply, ClientState}.

do_info(timeout, ClientState) ->
    NClientState = recv_packet(ClientState),
    {noreply, NClientState};

do_info({inet_async, S, Ref, Packet}, ClientState) when ClientState#client_state.sock =:= S
                    andalso  ClientState#client_state.recv_ref =:= Ref ->
    %% todo
    io:format("######Packet:~p~n", [Packet]),
    {ok, Cmd, Data} = reivse_packet(Packet),
    NNClientState =
    case routing(Cmd, Data) of
        {ok, rolelist, NData} ->
            NClientState = pp_login:get_rolelist(ClientState, NData),
            NClientState;
        {ok, create, NData} ->
            NClientState = pp_login:create_role(ClientState, NData),
            NClientState;
        {ok, login, NData} ->
            NClientState = pp_login:login_role(ClientState, NData),
            NClientState;
        {ok, Cmd, NData} ->
            %% 应该cast到玩家进程去执行的
            NClientState = cast_logic_solve_data_to_user(ClientState, Cmd, NData),
            NClientState
    end,
    {noreply, NNClientState};

do_info({'EXIT', S, _Reason}, ClientState) when ClientState#client_state.sock =:=  S ->
    io:format("####sock is closed, the reason is:~p~n", [_Reason]),
    {noreply, ClientState};

do_info(_Info, ClientState) ->
    io:format("#### do_info msg:~p is undefined.~n", [_Info]),
    {noreply, ClientState}.

recv_packet(ClientState) ->
    Sock = ClientState#client_state.sock,
    NClientState =
        case prim_inet:recv(Sock, 0) of
        {ok, Ref} ->
            ClientState#client_state{recv_ref = Ref};
        Error ->
            io:format("####prim_inet recv error:~p~n", [Error]),
            ClientState
        end,
    {noreply, NClientState}.

%% todo 解包
reivse_packet(Packet) ->
    Packet.


%% 用配套的协议解析文件解析
routing(Cmd, Data) ->
    {ok, Cmd, Data}.

cast_logic_solve_data_to_user(ClientState, _Cmd, _NData) ->
    ClientState.
