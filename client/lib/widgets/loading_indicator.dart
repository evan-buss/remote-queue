import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final int port;

  LoadingIndicator(this.port);

  @override
  Widget build(BuildContext context) {
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
}
