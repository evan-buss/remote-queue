import 'dart:io';

import 'package:client/models/computer.dart';
import 'package:client/screens/game_confirmation.dart';
import 'package:client/util/net_isolate.dart';
import 'package:client/widgets/loading_indicator.dart';
import 'package:client/widgets/port_sheet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final client = new http.Client();
  final Set<Computer> addresses = Set<Computer>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int port = 5001;
  bool isLoading = true;
  Stream<String> netStream;
  final TextEditingController controller = TextEditingController();

  String errorString = "Unable to locate your computer.";

  @override
  void initState() {
    super.initState();
    netStream = NetworkScanner.scanNetwork("192.168.1", port);
  }

  @override
  void dispose() {
    super.dispose();
    widget.client.close();
    controller.dispose();
    print("Disposing");
  }

  /// checkIP checks if the found IP is actually running the server.
  /// Returns a new [Computer] if so, otherwise returns null
  Future<Computer> checkIP(String ip) async {
    try {
      var response = await http.get("http://$ip:$port/poll");
      if (response.statusCode == 200) {
        return Computer(response.body, ip, port: port.toString());
      }
    } catch (ex) {
      print("GET error");
    } // Expected error, ignore exception
    return null;
  }

  // Show a ModalBottomSheet to change port number
  void _changePort() async {
    controller.text = port.toString();
    await showModalBottomSheet<int>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return PortSheet(controller);
      },
    );

    setState(() {
      port = int.parse(controller.text) ?? port;
      netStream = NetworkScanner.scanNetwork("192.168.1", port);
    });
  }

  Future<String> _reload() {
    setState(() {
      widget.addresses.clear();
      isLoading = true;
      netStream = NetworkScanner.scanNetwork("192.168.1", port);
    });

    return Future.value("RELOAD");
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
            //  Stop loading on error
            if (snapshot.hasError) {
              isLoading = false;
              errorString = snapshot.error.toString();
            }
            // Check to see if the open port is actually running the server
            if (snapshot.hasData) {
              checkIP(snapshot.data).then((computer) {
                if (computer != null) {
                  widget.addresses.add(computer);
                }
              });
            }
            // Generate a ListTile for each computer found
            var items = widget.addresses.map<Widget>(
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
              if (widget.addresses.length == 0) {
                errorString = "Unable to locate your computer.";
                return ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        errorString,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w300),
                      ),
                    ),
                  ],
                );
              }
            } else {
              items.insert(0, LoadingIndicator(port));
            }

            return ListView(children: items);
          },
        ),
      ),
    );
  }
}
