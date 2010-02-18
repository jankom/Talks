-module(dispatch).
-export([listen/1]).
-define(TCP_OPTIONS,[list, {packet, 0}, {active, false}, {reuseaddr, true}]).

listen(Port) ->
    register(manager, spawn(fun() -> manage_clients([]) end)),
    {ok, LSock} = gen_tcp:listen(Port, ?TCP_OPTIONS),
    do_accept(LSock).

do_accept(LSock) ->
    {ok, Sock} = gen_tcp:accept(LSock),
    spawn(fun() -> handle_client(Sock) end),
    manager ! {connect, Sock},
    do_accept(LSock).

manage_clients(Socks) ->
    receive
        {connect, Sock} -> 
			gen_tcp:send(Sock, "!Welcome!")
			NewSocks = [Sock | Socks];
        {disconnect, Sock} -> 
			NewSocks = lists:delete(Sock, Socks);
        {data, Data} -> 
			send_to_all(Socks, Data), 
			NewSocks = Socks
    end,
    manage_clients(NewSocks).

handle_client(Sock) ->
    case gen_tcp:recv(Sock, 0) of
        {ok, Data} -> manager ! {data, Data}, handle_client(Sock);
        {error, closed} -> manager ! {disconnect, Sock}
    end.

send_to_all(Socks, Data) ->
    lists:foreach(
		fun(Sock) -> gen_tcp:send(Sock, Data) end, Socks
	).
