%%%-------------------------------------------------------------------
%%% @author gaohongwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 二月 2017 下午10:58
%%%-------------------------------------------------------------------
-module(tcp_accepter).
-author("gaohongwei").

-behaviour(gen_server).

%% API
-export([start_link/2]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {accepter_name, lsock}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link(AccepterNum::integer(), LSock::term()) ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link(AccepterNum, LSock) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [AccepterNum, LSock], []).

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
    {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init([AccepterNum, LSock]) ->
    AccepterName = create_accepter_worker_name(AccepterNum),
    register(self(), AccepterName),
    case prim_inet:async_accept(LSock, infinity) of
        {ok, _} ->
            {ok, #state{lsock = LSock, accepter_name = AccepterName}};
        Error ->
            %% todo need logger sys
            lager:info("create accepter worker:~p error, the error is :~p~n", [AccepterName, Error]),
            {stop, error}
    end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_call(Request :: term(), From :: {pid(), Tag :: term()},
    State :: #state{}) ->
    {reply, Reply :: term(), NewState :: #state{}} |
    {reply, Reply :: term(), NewState :: #state{}, timeout() | hibernate} |
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), Reply :: term(), NewState :: #state{}} |
    {stop, Reason :: term(), NewState :: #state{}}).
handle_call(Info, _From, State) ->
    try
        do_call(Info, _From, State)
    catch
        _:Reason  ->
            lager:error("do_call info:~p wrong, the reason is:~p~n", [Info, Reason]),
            {reply, error, State}
    end.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @end
%%--------------------------------------------------------------------
-spec(handle_cast(Request :: term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
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
-spec(handle_info(Info :: timeout() | term(), State :: #state{}) ->
    {noreply, NewState :: #state{}} |
    {noreply, NewState :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term(), NewState :: #state{}}).
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
    State :: #state{}) -> term()).
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
-spec(code_change(OldVsn :: term() | {down, term()}, State :: #state{},
    Extra :: term()) ->
    {ok, NewState :: #state{}} | {error, Reason :: term()}).
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
create_accepter_worker_name(AccepterNum) ->
    list_to_atom(lists:concat(["accepter_worker_", AccepterNum])).

do_call(_Info, _From, State) ->
    io:format("#### do_call msg:~p is undefined.~n", [_Info]),
    {reply, error, State}.

do_cast(_Info, State) ->
    io:format("#### do_cast msg:~p is undefined.~n", [_Info]),
    {noreply, State}.

do_info({inet_async, L, _Ref, {ok, S}}, State) when L =:= State#state.lsock ->
    case start_client(S) of
    ok ->
        case prim_inet:async_accept(L, infinity) of
        {ok, _} ->
            {noreply, State};
        Error ->
            %% todo need logger sys
            io:format("create accepter worker:~p error, the error is :~p~n", [State#state.accepter_name, Error]),
            {stop, error}
        end
    end;

do_info({inet_acync, _L, _Ref, Error}, State) ->
    io:format("#### do_info accept error:~p~n", [Error]),
    {noreply, State};
do_info(_Info, State) ->
    io:format("#### do_info msg:~p is undefined.~n", [_Info]),
    {noreply, State}.

start_client(S) ->
    case tcp_client_sup:start_child(S) of
    {ok, Pid} when is_pid(Pid) ->
        case gen_tcp:controlling_process(S, Pid) of
        {error, Reason} ->
            %% 没有将Sock转移出去 应该是发生了不可预知的错误
            io:format("#########gen_tcp controllint process is error, the reason is :~p~n", [Reason]),
            error;
        ok ->
            %% Sock 转移了出去
            %% todo 这里在需要自己再去关闭一下socket么。 会不会都关掉 会
            %% gen_tcp:close(S)
            ok
        end;
    {error, Error} ->
        io:format("###### tcp_client_sup start child error, The Error is:~p~n", [Error]),
        error
    end.
