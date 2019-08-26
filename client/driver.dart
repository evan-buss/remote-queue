import 'package:client/util/net_isolate.dart';

void main() async {
  NetworkScanner.scanNetwork("192.168.1", 99999).listen((data) {
    print(data);
  }, onError: (err) {
    print("ERROR");
  });
}
