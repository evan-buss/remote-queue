import 'package:client/models/computer.dart';
import 'package:client/screens/game_confirmation.dart';
import 'package:client/util/net_isolate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final client = new http.Client();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Set<Computer> addresses = Set<Computer>();
  int scannedCounter = 0;
  bool isLoading = false;
  int port = 1337;
  List<String> addresses = List();

  @override
  void initState() {
    super.initState();
    // scanNetwork(port).then((result) {
    //   setState(() {
    //     isLoading = false;
    //     addresses = result;
    //   });
    // });
  }

  @override
  void dispose() {
    widget.client.close();
    print("Disposing");
    super.dispose();
  }

  Future<String> checkIP(String ip) async {
    var response = await http.get("http://$ip:$port/poll");
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  Widget _scanningProgress() {
    // Show the current scanning progress
    return Column(
      children: <Widget>[
        LinearProgressIndicator(),
        Text(
          "Scanning Your Local Network on Port $port",
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Computers"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                addresses.clear();
                isLoading = true;
              });

              print(port);
              var result = await scanNetwork(port);
              print(result);
              setState(() {
                isLoading = false;
                addresses = result;
              });
            },
          )
        ],
      ),
      body: ListView(
        children: addresses.map<Widget>((String x) {
          return ListTile(
            title: Text(x),
          );
        }).toList()
          ..insert(
            0,
            isLoading ? _scanningProgress() : Container(),
          ),
      ),
    );
  }
}
