-module(tcp_server_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, temporary, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

%% 启动两个 一个是tcp_listener_sup 一个是tcp_acceptor_sup
init([]) ->
    Children =
    [
        ?CHILD(tcp_listener_sup, supervisor),
        ?CHILD(tcp_client_sup, supervisor)
    ],
    RestartStrategy = {one_for_one, 0, 1},
    {ok, { RestartStrategy, Children} }.

