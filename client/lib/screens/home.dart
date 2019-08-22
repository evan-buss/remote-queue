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
      scannedCounter++;
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
          if (ip.connectionState == ConnectionState.done) {
            print("DONE");
            isLoading = false;
            if (addresses.length == 0) {
              return Center(child: Text("Unable to locate your computer."));
            }
          }

          // Increment each time a value is recieved
          // scannedCounter++;
          // Try to get hostname from server
          if (ip.hasData) {
            checkIP(ip.data.ip).then((result) {
              if (result != null) {
                addresses.add(Computer(result, ip.data.ip));
              }
            });
          }

          // Display a list of the computers found
          if (addresses.length > 0) {
            var items = addresses.map<Widget>((Computer computer) {
              return ListTile(
                leading: Icon(Icons.computer),
                title: Text(computer.hostname),
                subtitle: Text(computer.ip),
                onTap: () {
                  if (checkIP(computer.ip) == null) {
                    var obj = addresses.where((x) {
                      return x.ip == computer.ip;
                    });
                    addresses.remove(obj);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameConfirmation(
                          computer: computer,
                        ),
                      ),
                    );
                  }
                },
              );
            }).toList();

            if (isLoading) {
              items.insert(
                  0, LinearProgressIndicator(value: scannedCounter / 255));
              items.insert(
                1,
                Text("Scanning Your Local Network on Port $port",
                    textAlign: TextAlign.center),
              );
              // 0, LinearProgressIndicator(value: scannedCounter / 255));
            }

            return ListView(children: items);
          }

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
        },
      ),
    );
  }
}
