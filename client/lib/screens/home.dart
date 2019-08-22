import 'package:client/models/computer.dart';
import 'package:client/screens/game_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final client = new http.Client();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<Computer> addresses = Set<Computer>();
  int scannedCounter = 0;
  var networkScanStream;
  bool isLoading = true;
  int port = 1337;

  @override
  void initState() {
    super.initState();
    networkScanStream = networkScanStream =
        NetworkAnalyzer.discover("192.168.1", port).map((x) {
      setState(() {
        scannedCounter++;
      });
      return x;
    }).where((ip) => ip.exists);
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
        LinearProgressIndicator(
          value: scannedCounter / 255,
        ),
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
            onPressed: () {
              setState(() {
                addresses.clear();
                scannedCounter = 0;
                isLoading = true;
                networkScanStream =
                    NetworkAnalyzer.discover("192.168.1", port).map((x) {
                  setState(() {
                    scannedCounter++;
                  });
                  return x;
                }).where((ip) => ip.exists);
              });
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: networkScanStream,
        builder: (BuildContext context, AsyncSnapshot<NetworkAddress> ip) {
          // If the stream closes, hide loading progress.
          if (ip.connectionState == ConnectionState.done) {
            isLoading = false;
            if (addresses.length == 0) {
              return Center(child: Text("Unable to locate your computer."));
            }
          }

          // If ip is found, check to make sure it is running our server
          // If it is, the request will return the computer's name.
          if (ip.hasData) {
            checkIP(ip.data.ip).then((result) {
              if (result != null) {
                addresses.add(Computer(result, ip.data.ip));
              }
            });
          }

          // If atleast a single computer is found, construct a listview
          if (addresses.length > 0) {
            // Return an array of ListTiles (one for each computer)
            var items = addresses.map<Widget>((Computer computer) {
              return ListTile(
                leading: Icon(Icons.computer),
                title: Text(computer.hostname),
                subtitle: Text(computer.ip),
                onTap: () async {
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
                },
              );
            }).toList();

            // Only show progress bar if we are still scanning the network
            if (isLoading) {
              items.insert(0, _scanningProgress());
            }

            return ListView(children: items);
          }

          return _scanningProgress();
        },
      ),
    );
  }
}
