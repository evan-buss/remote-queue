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

  @override
  void initState() {
    super.initState();
    networkScanStream = NetworkAnalyzer.discover("192.168.1", 1337)
        .where((ip) => ip.exists); // initial stream
  }

  @override
  void dispose() {
    widget.client.close();
    print("Disposing");
    super.dispose();
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
                scannedCounter = 0;
                addresses.clear();
                networkScanStream = NetworkAnalyzer.discover("192.168.1", 1337)
                    .where((ip) => ip.exists);
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
            try {
              http
                  .get("http://${ip.data.ip}:1337/poll")
                  .then((http.Response response) {
                if (response.statusCode == 200) {
                  addresses.add(Computer(response.body, ip.data.ip));
                }
              });
            } catch (ex) {
              print("ERROR POLLING: " + ex);
            }
          }

          // Display a list of the computers found
          if (addresses.length > 0) {
            var items = addresses.map<Widget>((Computer computer) {
              return ListTile(
                leading: Icon(Icons.computer),
                title: Text(computer.hostname),
                subtitle: Text(computer.ip),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameConfirmation(
                        computer: computer,
                      ),
                    ),
                  );
                },
              );
            }).toList();

            if (isLoading) {
              items.insert(0, LinearProgressIndicator());
              // 0, LinearProgressIndicator(value: scannedCounter / 255));
            }

            return ListView(children: items);
          }

          // Show the current scanning progress
          return LinearProgressIndicator(
              // value: scannedCounter / 255,
              );
        },
      ),
    );
  }
}
