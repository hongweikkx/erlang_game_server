%%%-------------------------------------------------------------------
%%% @author gaohongwei
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%      listen and accept the tcp connect
%%% @end
%%% Created : 20. 二月 2017 下午10:33
%%%-------------------------------------------------------------------
-module(tcp_listener_sup).
-author("gaohongwei").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).
%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, temporary, 5000, Type, [I]}).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @end
%%--------------------------------------------------------------------
-spec(start_link() ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
    {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
        MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
        [ChildSpec :: supervisor:child_spec()]
    }} |
    ignore |
    {error, Reason :: term()}).
init([]) ->
    RestartStrategy = {one_for_one, 0, 1},
    Children =
    [
        ?CHILD(tcp_listener, worker),
        ?CHILD(tcp_accepter_sup, supervisor)
    ],
    {ok, {RestartStrategy, Children}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
