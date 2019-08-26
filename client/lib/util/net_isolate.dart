import 'dart:async';
import 'dart:io';
import 'dart:isolate';

/// IsolateParams contains information that each isolate uses.
/// [start] - the port the search should start at (inclusive)
/// [end] - the port the search should end at (inclusive)
/// [port] - the port to search for on the subnet
/// [sendPort] - the port that messages can be passed through
class IsolateParams {
  final int start;
  final int end;
  final String subnet;
  final int port;
  final SendPort sendPort;

  IsolateParams(this.start, this.end, this.subnet, this.port, this.sendPort);
}

/// NetworkScanner cotains network scanning functions
class NetworkScanner {
  /// scanNetwork searchs the given [subnet] for the open [port]
  static Stream<String> scanNetwork(String subnet, int port) {
    final isolateCount = 5; // # of isolates to be spawned

    List<Isolate> isolates = List(isolateCount);
    List<ReceivePort> ports = List(isolateCount);

    IsolateParams params;
    int doneCounter = 0;
    StreamController<String> controller = StreamController<String>();

    if (port < 1 || port > 65535) {
      // Return early before spawning threads if invalid port;
      controller.close();
      return controller.stream;
    }

    // Create isolates to search pieces of the subnet concurrently
    for (int i = 0; i < isolateCount; i++) {
      ports[i] = ReceivePort();
      if (i == 0) {
        params =
            IsolateParams(i + 1, (i + 1) * 51, subnet, port, ports[i].sendPort);
      } else {
        params = IsolateParams(
            i * 51, (i + 1) * 51, subnet, port, ports[i].sendPort);
      }
      // Spawn the isolate with the given params
      Isolate.spawn(_scanPartial, params).then((isolate) {
        isolates[i] = isolate;
        // Each isolate sends "DONE" when finished processing.
        isolates[i].addOnExitListener(ports[i].sendPort, response: "DONE");
      });

      // Listen for data from each isolate.
      ports[i].listen((data) {
        if (data != "DONE") {
          controller.add(data);
        } else {
          doneCounter++;
          ports[i].close();
          // Wait for all isolates to finish, then return results
          if (doneCounter == isolateCount) {
            controller.close();
          }
        }
      });
    }
    return controller.stream;
  }

  /// _scanPartial is responsible for scanning a subsection of the subnet
  static _scanPartial(IsolateParams params) async {
    for (int i = params.start; i <= params.end; ++i) {
      final host = '${params.subnet}.$i';

      try {
        final Socket s = await Socket.connect(host, params.port,
            timeout: Duration(milliseconds: 100));
        s.destroy();
        s.close();
        params.sendPort.send(host);
      } catch (e) {
        if (!(e is SocketException)) {
          rethrow;
        }
        // 13: Connection failed (OS Error: Permission denied)
        // 49: Bind failed (OS Error: Can't assign requested address)
        // 61: OS Error: Connection refused
        // 64: Connection failed (OS Error: Host is down)
        // 65: No route to host
        // 101: Network is unreachable
        // 111: Connection refused
        // 113: No route to host
        // <empty>: SocketException: Connection timed out
        final errorCodes = [13, 49, 61, 64, 65, 101, 111, 113];

        // Check if connection timed out or we got one of predefined errors
        if (e.osError == null || errorCodes.contains(e.osError.errorCode)) {
          // These are expected errors, don't raise any exceptions
        } else {
          // 23,24: Too many open files in system
          rethrow;
        }
      }
    }
  }
}
