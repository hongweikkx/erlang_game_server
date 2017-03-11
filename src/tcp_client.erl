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

-record(client_state, {sock,
        state = ?CLIENT_STATE_UNLOGIN,
        recv_ref}).

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
do_call(_Info, _From, State) ->
    io:format("#### do_call msg:~p is undefined.~n", [_Info]),
    {reply, error, State}.

do_cast(_Info, State) ->
    io:format("#### do_cast msg:~p is undefined.~n", [_Info]),
    {noreply, State}.

do_info(timeout, State) ->
    NState = recv_packet(State),
    {noreply, NState};

do_info({inet_async, S, Ref, Packet}, State) when State#client_state.sock =:= S
                    andalso  State#client_state.recv_ref =:= Ref ->
    io:format("######Status:~p~n", [Packet]),
    _Packet = unpack_packet(Packet),
    %% todo 处理包
    NState = recv_packet(S),
    {noreply, NState};

do_info({'EXIT', S, _Reason}, State) when State#client_state.sock =:=  S ->
    io:format("####sock is closed, the reason is:~p~n", [_Reason]),
    {noreply, State};

do_info(_Info, State) ->
    io:format("#### do_info msg:~p is undefined.~n", [_Info]),
    {noreply, State}.

recv_packet(State) ->
    Sock = State#client_state.sock,
    NState =
        case prim_inet:recv(Sock, 0) of
        {ok, Ref} ->
            State#client_state{recv_ref = Ref};
        Error ->
            io:format("####prim_inet recv error:~p~n", [Error]),
            State
        end,
    {noreply, NState}.

unpack_packet(_Status) ->
    %%todo
    ok.
