import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  var client = new http.Client();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<String> addresses = Set<String>();
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: StreamBuilder(
        stream: NetworkAnalyzer.discover("192.168.1", 1337),
        builder: (BuildContext context, AsyncSnapshot<NetworkAddress> ip) {
          switch (ip.connectionState) {
            case ConnectionState.done:
              isLoading = false;
              print("DONE");
              break;
            case ConnectionState.waiting:
              isLoading = true;
              break;
            default:
          }

          if (ip.hasData && ip.data.exists) {
            print(ip.data.ip);
            // addresses.add(ip.data.ip);
            http
                .get("http://${ip.data.ip}:1337/poll")
                .then((http.Response response) {
              if (response.statusCode == 200) {
                addresses.add(response.body);
              }
            });
          }
          if (addresses.length > 0) {
            return ListView(
              children: addresses.map<ListTile>((String address) {
                return ListTile(
                  title: Text(address),
                  onTap: () {
                    Navigator.pushNamed(context, "/game");
                  },
                );
              }).toList()
                ..add(isLoading
                    ? ListTile(
                        leading: CircularProgressIndicator(),
                        title: Text("Scanning network for more devices"))
                    : ListTile()),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
