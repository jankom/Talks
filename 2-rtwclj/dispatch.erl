-module(basicchat).
-export([listen/1]).

-define(TCP_OPTIONS,[list, {packet, 0}, {active, false}, {reuseaddr, true}]).

listen(Port) ->
    Pid = spawn(fun() -> manage_clients([]) end),
    register(client_manager, Pid),
    {ok, LSocket} = gen_tcp:listen(Port, ?TCP_OPTIONS),
    do_accept(LSocket).

do_accept(LSocket) ->
    {ok, Socket} = gen_tcp:accept(LSocket),
    spawn(fun() -> handle_client(Socket) end),
    client_manager ! {connect, Socket},
    do_accept(LSocket).

handle_client(Socket) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
            client_manager ! {data, Data},
            handle_client(Socket);
        {error, closed} ->
            client_manager ! {disconnect, Socket}
    end.

manage_clients(Sockets) ->
    receive
        {connect, Socket} ->
            NewSockets = [Socket | Sockets];
        {disconnect, Socket} ->
            NewSockets = lists:delete(Socket, Sockets);
        {data, Data} ->
            send_data(Sockets, Data),
            NewSockets = Sockets
    end,
    manage_clients(NewSockets).

send_data(Sockets, Data) ->
    SendData = fun(Socket) ->
                       gen_tcp:send(Socket, Data)
               end,
    lists:foreach(SendData, Sockets).
