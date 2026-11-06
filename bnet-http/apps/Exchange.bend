# Shared client and server for the header exchange.
# The session forks a server, connects, and checks one success path and
# three failure modes. UDP.poll reads the non-blocking TCP socket, so a
# silent peer becomes a retry and then a timeout.
import Base
import ./../Protocol.bend as Net

def one_char(n: U32) -> String:
  String.from_list(Char.from_u32(n) <> Nil{})

def octets_text(xs: List<U32>) -> String:
  match xs:
    case Nil{}:
      ""
    case Con{head, tail}:
      String.append(one_char(head), octets_text(tail))

def chars_octets(cs: List<&2, Char>) -> List<U32>:
  match cs:
    case Nil{}:
      Nil{}
    case Con{head, tail}:
      Char.to_u32(head) <> chars_octets(tail)

def text_octets(s: String) -> List<U32>:
  chars_octets(String.to_list(s))

def request_frame() -> Net.HttpRequest:
  Net.HttpRequest{1, 1, 1, 0}

def reply_frame() -> Net.HttpRequest:
  Net.HttpRequest{2, 1, 1, 0}

def request_text() -> String:
  octets_text(Net.build_header(request_frame()))

def reply_text() -> String:
  octets_text(Net.build_header(reply_frame()))

def listen_port() -> U32:
  19107

def refused_port() -> U32:
  20107

def payload(got: String & U32 & String) -> String:
  (host, rest) = got
  (port, text) = rest
  text

def fail_closed(sock: Socket) -> IO(Unit):
  do IO<Unit>:
    closed : Unit <- Socket.close(sock)
    IO.print("ERROR closed")

def fail_timeout(sock: Socket) -> IO(Unit):
  do IO<Unit>:
    closed : Unit <- Socket.close(sock)
    IO.print("ERROR timeout")

def report_last(prefix: String, sock: Socket, line: String, ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      do IO<Unit>:
        closed : Unit <- Socket.close(sock)
        IO.print(prefix ++ line)
    case False{}:
      do IO<Unit>:
        closed : Unit <- Socket.close(sock)
        IO.print("ERROR value")

def judge_last(prefix: String, sock: Socket, +msg: Net.HttpRequest) -> IO(Unit):
  report_last(prefix, sock, Net.label(msg), Net.same_frame(msg, reply_frame()))

def take_last(prefix: String, sock: Socket, text: String, empty: Bool) -> IO(Unit):
  match empty:
    case True{}:
      fail_closed(sock)
    case False{}:
      judge_last(prefix, sock, Net.parse_header(text_octets(text)))

def show_last(prefix: String, sock: Socket, +text: String) -> IO(Unit):
  take_last(prefix, sock, text, String.is_empty(text))

def finish_last(got: Socket & Result<&1, &1, U32 & String, Maybe<&1, String & U32 & String>>, prefix: String) -> IO(Unit):
  (sock, result) = got
  match result:
    case Fail{(code, message)}:
      fail_closed(sock)
    case Done{None{}}:
      fail_timeout(sock)
    case Done{Some{value}}:
      show_last(prefix, sock, payload(value))

def drive_last(tries: Nat, got: Socket & Result<&1, &1, U32 & String, Maybe<&1, String & U32 & String>>, prefix: String) -> IO(Unit):
  match tries:
    case 0n:
      finish_last(got, prefix)
    case 1n+p:
      match got:
        case (sock, Fail{(code, message)}):
          fail_closed(sock)
        case (sock, Done{None{}}):
          do IO<Unit>:
            IO.sleep(20)
            polled : Socket & Result<&1, &1, U32 & String, Maybe<&1, String & U32 & String>> <- UDP.poll(sock, 256)
            drive_last(p, polled, prefix)
        case (sock, Done{Some{value}}):
          show_last(prefix, sock, payload(value))

def after_send_last(prefix: String, got: Socket & Result<&1, &1, U32 & String, Unit>) -> IO(Unit):
  (sock, result) = got
  match result:
    case Fail{(code, message)}:
      fail_closed(sock)
    case Done{value}:
      do IO<Unit>:
        polled : Socket & Result<&1, &1, U32 & String, Maybe<&1, String & U32 & String>> <- UDP.poll(sock, 256)
        drive_last(8n, polled, prefix)

def report_more(prefix: String, sock: Socket, line: String, ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      do IO<Unit>:
        IO.print(prefix ++ line)
        sent : Socket & Result<&1, &1, U32 & String, Unit> <- TCP.send(sock, request_text())
        after_send_last("OK ", sent)
    case False{}:
      do IO<Unit>:
        closed : Unit <- Socket.close(sock)
        IO.print("ERROR value")

def judge_more(prefix: String, sock: Socket, +msg: Net.HttpRequest) -> IO(Unit):
  report_more(prefix, sock, Net.label(msg), Net.same_frame(msg, reply_frame()))

def take_more(prefix: String, sock: Socket, text: String, empty: Bool) -> IO(Unit):
  match empty:
    case True{}:
      fail_closed(sock)
    case False{}:
      judge_more(prefix, sock, Net.parse_header(text_octets(text)))

def show_more(prefix: String, sock: Socket, +text: String) -> IO(Unit):
  take_more(prefix, sock, text, String.is_empty(text))

def finish_more(got: Socket & Result<&1, &1, U32 & String, Maybe<&1, String & U32 & String>>, prefix: String) -> IO(Unit):
  (sock, result) = got
  match result:
    case Fail{(code, message)}:
      fail_closed(sock)
    case Done{None{}}:
      fail_timeout(sock)
    case Done{Some{value}}:
      show_more(prefix, sock, payload(value))

def drive_more(tries: Nat, got: Socket & Result<&1, &1, U32 & String, Maybe<&1, String & U32 & String>>, prefix: String) -> IO(Unit):
  match tries:
    case 0n:
      finish_more(got, prefix)
    case 1n+p:
      match got:
        case (sock, Fail{(code, message)}):
          fail_closed(sock)
        case (sock, Done{None{}}):
          do IO<Unit>:
            IO.sleep(20)
            polled : Socket & Result<&1, &1, U32 & String, Maybe<&1, String & U32 & String>> <- UDP.poll(sock, 256)
            drive_more(p, polled, prefix)
        case (sock, Done{Some{value}}):
          show_more(prefix, sock, payload(value))

def after_send_more(prefix: String, got: Socket & Result<&1, &1, U32 & String, Unit>) -> IO(Unit):
  (sock, result) = got
  match result:
    case Fail{(code, message)}:
      fail_closed(sock)
    case Done{value}:
      do IO<Unit>:
        polled : Socket & Result<&1, &1, U32 & String, Maybe<&1, String & U32 & String>> <- UDP.poll(sock, 256)
        drive_more(8n, polled, prefix)

def finish_wait(got: Socket & Result<&1, &1, U32 & String, Maybe<&1, String & U32 & String>>) -> IO(Unit):
  (sock, result) = got
  match result:
    case Fail{(code, message)}:
      fail_closed(sock)
    case Done{None{}}:
      fail_timeout(sock)
    case Done{Some{value}}:
      show_last("OK ", sock, payload(value))

def drive_wait(tries: Nat, got: Socket & Result<&1, &1, U32 & String, Maybe<&1, String & U32 & String>>) -> IO(Unit):
  match tries:
    case 0n:
      finish_wait(got)
    case 1n+p:
      match got:
        case (sock, Fail{(code, message)}):
          fail_closed(sock)
        case (sock, Done{None{}}):
          do IO<Unit>:
            IO.print("RETRY")
            IO.sleep(30)
            polled : Socket & Result<&1, &1, U32 & String, Maybe<&1, String & U32 & String>> <- UDP.poll(sock, 256)
            drive_wait(p, polled)
        case (sock, Done{Some{value}}):
          show_last("OK ", sock, payload(value))

def after_send_wait(got: Socket & Result<&1, &1, U32 & String, Unit>) -> IO(Unit):
  (sock, result) = got
  match result:
    case Fail{(code, message)}:
      fail_closed(sock)
    case Done{value}:
      do IO<Unit>:
        polled : Socket & Result<&1, &1, U32 & String, Maybe<&1, String & U32 & String>> <- UDP.poll(sock, 256)
        drive_wait(2n, polled)

def begin_pair(sock: Socket) -> IO(Unit):
  do IO<Unit>:
    IO.print("CONNECT")
    sent : Socket & Result<&1, &1, U32 & String, Unit> <- TCP.send(sock, request_text())
    after_send_more("OK ", sent)

def begin_bad(sock: Socket) -> IO(Unit):
  do IO<Unit>:
    IO.print("CONNECT")
    sent : Socket & Result<&1, &1, U32 & String, Unit> <- TCP.send(sock, request_text())
    after_send_last("OK ", sent)

def begin_closed(sock: Socket) -> IO(Unit):
  do IO<Unit>:
    IO.print("CONNECT")
    sent : Socket & Result<&1, &1, U32 & String, Unit> <- TCP.send(sock, request_text())
    after_send_last("OK ", sent)

def begin_silent(sock: Socket) -> IO(Unit):
  do IO<Unit>:
    IO.print("CONNECT")
    sent : Socket & Result<&1, &1, U32 & String, Unit> <- TCP.send(sock, request_text())
    after_send_wait(sent)

def on_pair(tries: Nat, result: Result<&1, &1, U32 & String, Socket>) -> IO(Unit):
  match tries:
    case 0n:
      match result:
        case Fail{(code, message)}:
          IO.print("ERROR refused")
        case Done{value}:
          begin_pair(value)
    case 1n+p:
      match result:
        case Fail{(code, message)}:
          do IO<Unit>:
            IO.sleep(20)
            got : Result<&1, &1, U32 & String, Socket> <- TCP.connect("127.0.0.1", listen_port())
            on_pair(p, got)
        case Done{value}:
          begin_pair(value)

def client_pair() -> IO(Unit):
  do IO<Unit>:
    got : Result<&1, &1, U32 & String, Socket> <- TCP.connect("127.0.0.1", listen_port())
    on_pair(3n, got)

def on_bad(tries: Nat, result: Result<&1, &1, U32 & String, Socket>) -> IO(Unit):
  match tries:
    case 0n:
      match result:
        case Fail{(code, message)}:
          IO.print("ERROR refused")
        case Done{value}:
          begin_bad(value)
    case 1n+p:
      match result:
        case Fail{(code, message)}:
          do IO<Unit>:
            IO.sleep(20)
            got : Result<&1, &1, U32 & String, Socket> <- TCP.connect("127.0.0.1", listen_port())
            on_bad(p, got)
        case Done{value}:
          begin_bad(value)

def client_bad() -> IO(Unit):
  do IO<Unit>:
    got : Result<&1, &1, U32 & String, Socket> <- TCP.connect("127.0.0.1", listen_port())
    on_bad(3n, got)

def on_closed(tries: Nat, result: Result<&1, &1, U32 & String, Socket>) -> IO(Unit):
  match tries:
    case 0n:
      match result:
        case Fail{(code, message)}:
          IO.print("ERROR refused")
        case Done{value}:
          begin_closed(value)
    case 1n+p:
      match result:
        case Fail{(code, message)}:
          do IO<Unit>:
            IO.sleep(20)
            got : Result<&1, &1, U32 & String, Socket> <- TCP.connect("127.0.0.1", listen_port())
            on_closed(p, got)
        case Done{value}:
          begin_closed(value)

def client_closed() -> IO(Unit):
  do IO<Unit>:
    got : Result<&1, &1, U32 & String, Socket> <- TCP.connect("127.0.0.1", listen_port())
    on_closed(3n, got)

def on_silent(tries: Nat, result: Result<&1, &1, U32 & String, Socket>) -> IO(Unit):
  match tries:
    case 0n:
      match result:
        case Fail{(code, message)}:
          IO.print("ERROR refused")
        case Done{value}:
          begin_silent(value)
    case 1n+p:
      match result:
        case Fail{(code, message)}:
          do IO<Unit>:
            IO.sleep(20)
            got : Result<&1, &1, U32 & String, Socket> <- TCP.connect("127.0.0.1", listen_port())
            on_silent(p, got)
        case Done{value}:
          begin_silent(value)

def client_silent() -> IO(Unit):
  do IO<Unit>:
    got : Result<&1, &1, U32 & String, Socket> <- TCP.connect("127.0.0.1", listen_port())
    on_silent(3n, got)

def on_refused(result: Result<&1, &1, U32 & String, Socket>) -> IO(Unit):
  match result:
    case Fail{(code, message)}:
      IO.print("ERROR refused")
    case Done{value}:
      do IO<Unit>:
        shut : Unit <- Socket.close(value)
        IO.print("ERROR unexpected")

def client_refused() -> IO(Unit):
  do IO<Unit>:
    got : Result<&1, &1, U32 & String, Socket> <- TCP.connect("127.0.0.1", refused_port())
    on_refused(got)

def close_sent(got: Socket & Result<&1, &1, U32 & String, Unit>) -> IO(Unit):
  (sock, result) = got
  do IO<Unit>:
    sent : Unit <- IO.pass(Unit, result)
    shut : Unit <- Socket.close(sock)
    return Unit{}

def on_second(got: Socket & Result<&1, &1, U32 & String, String>) -> IO(Unit):
  (sock, result) = got
  match result:
    case Fail{(code, message)}:
      do IO<Unit>:
        shut : Unit <- Socket.close(sock)
        return Unit{}
    case Done{value}:
      do IO<Unit>:
        sent : Socket & Result<&1, &1, U32 & String, Unit> <- TCP.send(sock, reply_text())
        close_sent(sent)

def after_first_send(got: Socket & Result<&1, &1, U32 & String, Unit>) -> IO(Unit):
  (sock, result) = got
  do IO<Unit>:
    sent : Unit <- IO.pass(Unit, result)
    rec : Socket & Result<&1, &1, U32 & String, String> <- TCP.recv(sock, 256)
    on_second(rec)

def on_first(got: Socket & Result<&1, &1, U32 & String, String>) -> IO(Unit):
  (sock, result) = got
  match result:
    case Fail{(code, message)}:
      do IO<Unit>:
        shut : Unit <- Socket.close(sock)
        return Unit{}
    case Done{value}:
      do IO<Unit>:
        sent : Socket & Result<&1, &1, U32 & String, Unit> <- TCP.send(sock, reply_text())
        after_first_send(sent)

def accepted_pair(got: Listener & Result<&1, &1, U32 & String, Socket>) -> IO(Unit):
  (listener, result) = got
  match result:
    case Fail{(code, message)}:
      do IO<Unit>:
        closed : Unit <- Listener.close(listener)
        IO.die(Unit, code, message)
    case Done{value}:
      do IO<Unit>:
        closed : Unit <- Listener.close(listener)
        rec : Socket & Result<&1, &1, U32 & String, String> <- TCP.recv(value, 256)
        on_first(rec)

def server_pair() -> IO(Unit):
  do IO<Unit>:
    listener : Listener <- IO.try(Listener, TCP.listen(listen_port()))
    acc : Listener & Result<&1, &1, U32 & String, Socket> <- TCP.accept(listener)
    accepted_pair(acc)

def on_bad_req(got: Socket & Result<&1, &1, U32 & String, String>) -> IO(Unit):
  (sock, result) = got
  match result:
    case Fail{(code, message)}:
      do IO<Unit>:
        shut : Unit <- Socket.close(sock)
        return Unit{}
    case Done{value}:
      do IO<Unit>:
        sent : Socket & Result<&1, &1, U32 & String, Unit> <- TCP.send(sock, request_text())
        close_sent(sent)

def accepted_bad(got: Listener & Result<&1, &1, U32 & String, Socket>) -> IO(Unit):
  (listener, result) = got
  match result:
    case Fail{(code, message)}:
      do IO<Unit>:
        closed : Unit <- Listener.close(listener)
        IO.die(Unit, code, message)
    case Done{value}:
      do IO<Unit>:
        closed : Unit <- Listener.close(listener)
        rec : Socket & Result<&1, &1, U32 & String, String> <- TCP.recv(value, 256)
        on_bad_req(rec)

def server_bad() -> IO(Unit):
  do IO<Unit>:
    listener : Listener <- IO.try(Listener, TCP.listen(listen_port()))
    acc : Listener & Result<&1, &1, U32 & String, Socket> <- TCP.accept(listener)
    accepted_bad(acc)

def accepted_reset(got: Listener & Result<&1, &1, U32 & String, Socket>) -> IO(Unit):
  (listener, result) = got
  match result:
    case Fail{(code, message)}:
      do IO<Unit>:
        closed : Unit <- Listener.close(listener)
        IO.die(Unit, code, message)
    case Done{value}:
      do IO<Unit>:
        closed : Unit <- Listener.close(listener)
        shut : Unit <- Socket.close(value)
        return Unit{}

def server_reset() -> IO(Unit):
  do IO<Unit>:
    listener : Listener <- IO.try(Listener, TCP.listen(listen_port()))
    acc : Listener & Result<&1, &1, U32 & String, Socket> <- TCP.accept(listener)
    accepted_reset(acc)

def hold_silent(got: Socket & Result<&1, &1, U32 & String, String>) -> IO(Unit):
  (sock, result) = got
  match result:
    case Fail{(code, message)}:
      do IO<Unit>:
        shut : Unit <- Socket.close(sock)
        return Unit{}
    case Done{value}:
      do IO<Unit>:
        IO.sleep(400)
        shut : Unit <- Socket.close(sock)
        return Unit{}

def accepted_silent(got: Listener & Result<&1, &1, U32 & String, Socket>) -> IO(Unit):
  (listener, result) = got
  match result:
    case Fail{(code, message)}:
      do IO<Unit>:
        closed : Unit <- Listener.close(listener)
        IO.die(Unit, code, message)
    case Done{value}:
      do IO<Unit>:
        closed : Unit <- Listener.close(listener)
        rec : Socket & Result<&1, &1, U32 & String, String> <- TCP.recv(value, 256)
        hold_silent(rec)

def server_silent() -> IO(Unit):
  do IO<Unit>:
    listener : Listener <- IO.try(Listener, TCP.listen(listen_port()))
    acc : Listener & Result<&1, &1, U32 & String, Socket> <- TCP.accept(listener)
    accepted_silent(acc)

def run_pair() -> IO(Unit):
  do IO<Unit>:
    chan : Chan(Unit) <- IO.fork(Unit, server_pair())
    IO.sleep(30)
    client_pair()
    done : Unit <- IO.join(Unit, chan)
    return done

def run_bad() -> IO(Unit):
  do IO<Unit>:
    chan : Chan(Unit) <- IO.fork(Unit, server_bad())
    IO.sleep(30)
    client_bad()
    done : Unit <- IO.join(Unit, chan)
    return done

def run_closed() -> IO(Unit):
  do IO<Unit>:
    chan : Chan(Unit) <- IO.fork(Unit, server_reset())
    IO.sleep(30)
    client_closed()
    done : Unit <- IO.join(Unit, chan)
    return done

def run_silent() -> IO(Unit):
  do IO<Unit>:
    chan : Chan(Unit) <- IO.fork(Unit, server_silent())
    IO.sleep(30)
    client_silent()
    done : Unit <- IO.join(Unit, chan)
    return done

def session_main() -> IO(Unit):
  do IO<Unit>:
    run_pair()
    run_bad()
    run_closed()
    run_silent()
    client_refused()

def show_server(sock: Socket, line: String, ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      do IO<Unit>:
        closed : Unit <- Socket.close(sock)
        IO.print("SERVER " ++ line)
    case False{}:
      do IO<Unit>:
        closed : Unit <- Socket.close(sock)
        IO.print("MISMATCH")

def sent_show(got: Socket & Result<&1, &1, U32 & String, Unit>, line: String) -> IO(Unit):
  (sock, result) = got
  do IO<Unit>:
    sent : Unit <- IO.pass(Unit, result)
    show_server(sock, line, True{})

def send_show(sock: Socket, line: String) -> IO(Unit):
  do IO<Unit>:
    sent : Socket & Result<&1, &1, U32 & String, Unit> <- TCP.send(sock, reply_text())
    sent_show(sent, line)

def decide_show(sock: Socket, line: String, ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      send_show(sock, line)
    case False{}:
      do IO<Unit>:
        closed : Unit <- Socket.close(sock)
        IO.print("MISMATCH")

def answer_show(sock: Socket, +msg: Net.HttpRequest) -> IO(Unit):
  decide_show(sock, Net.label(msg), Net.same_frame(msg, request_frame()))

def on_text_show(sock: Socket, text: String) -> IO(Unit):
  answer_show(sock, Net.parse_header(text_octets(text)))

def on_recv_show(got: Socket & Result<&1, &1, U32 & String, String>) -> IO(Unit):
  (sock, result) = got
  match result:
    case Fail{(code, message)}:
      do IO<Unit>:
        closed : Unit <- Socket.close(sock)
        IO.die(Unit, code, message)
    case Done{value}:
      on_text_show(sock, value)

def on_accept_show(got: Listener & Result<&1, &1, U32 & String, Socket>) -> IO(Unit):
  (listener, result) = got
  do IO<Unit>:
    closed : Unit <- Listener.close(listener)
    sock : Socket <- IO.pass(Socket, result)
    rec : Socket & Result<&1, &1, U32 & String, String> <- TCP.recv(sock, 256)
    on_recv_show(rec)

def server_show() -> IO(Unit):
  do IO<Unit>:
    listener : Listener <- IO.try(Listener, TCP.listen(listen_port()))
    acc : Listener & Result<&1, &1, U32 & String, Socket> <- TCP.accept(listener)
    on_accept_show(acc)

def pick_silent(name: String, yes: Bool) -> IO(Unit):
  match yes:
    case True{}:
      do IO<Unit>:
        IO.print("MODE silent")
        server_silent()
    case False{}:
      IO.print("ERROR mode")

def pick_reset(+name: String, yes: Bool) -> IO(Unit):
  match yes:
    case True{}:
      do IO<Unit>:
        IO.print("MODE reset")
        server_reset()
    case False{}:
      pick_silent(name, String.eq(name, "silent"))

def pick_bad(+name: String, yes: Bool) -> IO(Unit):
  match yes:
    case True{}:
      do IO<Unit>:
        IO.print("MODE bad")
        server_bad()
    case False{}:
      pick_reset(name, String.eq(name, "reset"))

def pick_ok(+name: String, yes: Bool) -> IO(Unit):
  match yes:
    case True{}:
      server_show()
    case False{}:
      pick_bad(name, String.eq(name, "bad"))

def on_env(got: Result<&1, &1, U32 & String, String>) -> IO(Unit):
  match got:
    case Fail{(code, message)}:
      server_show()
    case Done{+value}:
      pick_ok(value, String.eq(value, "ok"))

def on_demo(result: Result<&1, &1, U32 & String, Socket>) -> IO(Unit):
  match result:
    case Fail{(code, message)}:
      IO.print("ERROR refused")
    case Done{value}:
      do IO<Unit>:
        sent : Socket & Result<&1, &1, U32 & String, Unit> <- TCP.send(value, request_text())
        after_send_last("CLIENT ", sent)

def demo_client() -> IO(Unit):
  do IO<Unit>:
    got : Result<&1, &1, U32 & String, Socket> <- TCP.connect("127.0.0.1", listen_port())
    on_demo(got)
