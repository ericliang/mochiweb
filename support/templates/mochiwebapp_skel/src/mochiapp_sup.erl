%% @author {{author}}
%% @copyright {{year}} {{author}}

%% @doc Supervisor for the {{appid}} application.

-module({{appid}}_sup).
-author("{{author}}").

-behaviour(supervisor).

%% External exports
-export([start_link/0, upgrade/0]).

%% supervisor callbacks
-export([init/1]).

%% @spec start_link() -> ServerRet
%% @doc API for starting the supervisor.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% @spec upgrade() -> ok
%% @doc Add processes if necessary.
upgrade() ->
    {ok, {_, Specs}} = init([]),

    Old = sets:from_list(
            [Name || {Name, _, _, _} <- supervisor:which_children(?MODULE)]),
    New = sets:from_list([Name || {Name, _, _, _, _, _} <- Specs]),
    Kill = sets:subtract(Old, New),

    sets:fold(fun (Id, ok) ->
                      supervisor:terminate_child(?MODULE, Id),
                      supervisor:delete_child(?MODULE, Id),
                      ok
              end, ok, Kill),

    [supervisor:start_child(?MODULE, Spec) || Spec <- Specs],
    ok.

%% @spec init([]) -> SupervisorTree
%% @doc supervisor callback.
init([]) ->
    Web = web_specs({{appid}}_web, {{port}}),
    Processes = [Web],
    Strategy = {one_for_one, 10, 10},
    {ok,
     {Strategy, lists:flatten(Processes)}}.

web_specs(Mod, DefaultPort) ->
	Ip = get_app_env( ip, {0,0,0,0} ),
	Port = get_app_env( port, DefaultPort ),

    WebConfig = [{ip, Ip},
                 {port, Port},
                 {docroot, {{appid}}_deps:local_path(["priv", "www"])}],
    {Mod,
     {Mod, start, [WebConfig]},
     permanent, 5000, worker, dynamic}.


get_app_env( Key, DefaultValue ) ->
	case application:get_env( {{appid}}, Key ) of
		{ok, Value } ->
			Value;
		_ ->
			DefaultValue
	end.
