import 'package:client/util/net_isolate.dart';

// Net scanner isolate test driver
void main() async {
  NetworkScanner.scanNetwork("192.168.1", 80).listen((data) {
    print(data);
  }, onError: (err) {
    print("ERROR");
  });
}
