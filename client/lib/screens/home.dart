import 'dart:io';

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
  Set<Computer> addresses = Set<Computer>();
  bool isLoading = true;
  int port = 5001;
  Stream<String> netStream;

  @override
  void initState() {
    super.initState();
    netStream = NetworkScanner.scanNetwork("192.168.1", port);
  }

  @override
  void dispose() {
    widget.client.close();
    print("Disposing");
    super.dispose();
  }

  Future<Computer> checkIP(String ip) async {
    try {
      var response = await http.get("http://$ip:$port/poll");
      if (response.statusCode == 200) {
        return Computer(response.body, ip, port: port.toString());
      }
    } on SocketException {} // Expected error, ignore exception
    return null;
  }

  Widget _scanningProgress() {
    // Show the current scanning progress
    return Column(
      children: <Widget>[
        LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Scanning Your Local Network on Port $port",
            textAlign: TextAlign.center,
          ),
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
                netStream = NetworkScanner.scanNetwork("192.168.1", port);
              });
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: netStream,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          // Check to see if the open port is actually running the server
          if (snapshot.hasData) {
            checkIP(snapshot.data).then((computer) {
              if (computer != null) {
                addresses.add(computer);
              }
            });
          }
          // Generate a ListTile for each computer found
          var items = addresses.map<Widget>(
            (computer) {
              return ListTile(
                leading: Icon(Icons.computer),
                title: Text(computer.hostname),
                subtitle: Text(computer.ip),
                onTap: () async {
                  if (await checkIP(computer.ip) != null) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameConfirmation(
                          computer: computer,
                        ),
                      ),
                    );
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Connection Closed"),
                      ),
                    );
                  } else {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Unable to connect to computer."),
                      ),
                    );
                  }
                },
              );
            },
          ).toList();

          if (snapshot.connectionState == ConnectionState.done) {
            isLoading = false;
            if (addresses.length == 0) {
              return Center(child: Text("Unable to locate your computer."));
            }
          } else {
            items.insert(0, _scanningProgress());
          }

          return ListView(children: items);
        },
      ),
    );
  }
}
