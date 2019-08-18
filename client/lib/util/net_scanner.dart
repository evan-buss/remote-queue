import 'package:ping_discover_network/ping_discover_network.dart';

/// Search for open connections on the given port
Future<List<String>> scan() async {
  final String subnet = '192.168.1';
  final int port = 1337;

  final List<String> found = List<String>();

  final stream = NetworkAnalyzer.discover(subnet, port);
  stream.listen((NetworkAddress addr) {
    if (addr.exists) {
      found.add(addr.ip);
    }
    print(addr.ip);
  })
    ..onError((error) {
      print("Network Discovery Error: $error");
      return null;
    })
    ..onDone(() {
      return found;
    });
}
