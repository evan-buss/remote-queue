import "package:client/util/net_isolate.dart";
import 'package:ping_discover_network/ping_discover_network.dart';

void main() async {
  var start = DateTime.now();
  List<String> results = await NetworkScanner.scanNetwork("192.168.1", 80);
  var end = DateTime.now();

  print("Isolate Time: " + start.difference(end).toString());
  print(results);

  start = DateTime.now();
  await for (NetworkAddress address
      in NetworkAnalyzer.discover("192.168.1", 80, timeout: Duration(milliseconds: 100))) {
    if (address.exists) {
      print(address.ip);
    }
  }
  end = DateTime.now();
  print("Network Analyzer Time: " + start.difference(end).toString());
}
