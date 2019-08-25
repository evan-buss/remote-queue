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
  TextEditingController controller = TextEditingController();

  Stream<String> netStream;

  @override
  void initState() {
    super.initState();
    netStream = NetworkScanner.scanNetwork("192.168.1", port);
  }

  @override
  void dispose() {
    widget.client.close();
    controller.dispose();
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
            "Scanning Network Port: $port",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
          ),
        )
      ],
    );
  }

  void _changePort() async {
    controller.text = port.toString();
    var newPort = await showModalBottomSheet<int>(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(
                "Server Port",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text("SAVE"),
                    onPressed: () {
                      Navigator.pop(
                          context, int.parse(controller.text ?? null));
                    },
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
            )
          ],
        );
      },
    );
    setState(() {
      port = newPort ?? port;
    });
  }

  Future<String> _reload() {
    setState(() {
      addresses.clear();
      isLoading = true;
      netStream = NetworkScanner.scanNetwork("192.168.1", port);
    });

    return Future.value("DONE");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Computers"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              _changePort();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: StreamBuilder(
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
                return ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Unable to locate your computer.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ),
                  ],
                );
              }
            } else {
              items.insert(0, _scanningProgress());
            }

            return ListView(children: items);
          },
        ),
      ),
    );
  }
}
