import 'package:client/models/computer.dart';
import 'package:client/util/message_handler.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class GameConfirmation extends StatefulWidget {
  final Computer computer;
  final IOWebSocketChannel channel;

  GameConfirmation({this.computer})
      : channel =
            IOWebSocketChannel.connect('ws://${computer.ip}:${computer.port}');

  @override
  _GameConfirmationState createState() => _GameConfirmationState();
}

class _GameConfirmationState extends State<GameConfirmation> {

  @override
  Widget build(BuildContext context) {
    print(widget.computer.ip);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.computer.hostname),
      ),
      body: StreamBuilder(
        stream: widget.channel.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Stream is done or interupted, go back to device list
            widget.channel.sink.close(status.normalClosure);
            Navigator.pop(context);
          }
          return snapshot.hasData
              ? MessageHandler(snapshot.data, context, widget.channel)
              : Text("no messages");
        },
      ),
    );
  }
}
