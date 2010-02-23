-module(dispatch).
-export([listen/1]).
-define(TCP_OPTIONS,[list, {packet, 0}, {active, false}, {reuseaddr, true}]).

listen(Port) ->
    register(manager, spawn(fun() -> manage([]) end)),
    {ok, LSock} = gen_tcp:listen(Port, ?TCP_OPTIONS),
    accept(LSock).

accept(LSock) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    spawn(fun() -> cli_hello(Sock) end),
    manager ! {new, Sock},
    accept(LSock).

manage(Socks) ->
    receive
        {new, Sock} -> NewSocks = [Sock | Socks];
        {died, Sock} -> NewSocks = lists:delete(Sock, Socks);
        {event, Data} -> send_all(Socks, Data), 
			NewSocks = Socks
    end,
    manage(NewSocks).

cli_hello(Sock) ->
	gen_tcp:send(Sock, "!Welcome!"),
	cli_dispatch(Sock).

cli_dispatch(Sock) ->
    case gen_tcp:recv(Sock, 0) of
        {ok, Data} -> manager ! {event, Data}, cli_dispatch(Sock);
        {error, closed} -> manager ! {died, Sock}
    end.

send_all(Socks, Data) ->
    lists:foreach(fun(Sock) -> gen_tcp:send(Sock, Data) end, Socks).
