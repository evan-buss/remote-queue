import 'package:client/models/computer.dart';
import 'package:client/widgets/message_handler.dart';
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
  Stream serverStream;

  @override
  void dispose() {
    widget.channel.sink.close();
    print("Disposing");
    super.dispose();
  }

  void leave(BuildContext context) {
    widget.channel.sink.close(status.normalClosure);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    serverStream = widget.channel.stream;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.computer.hostname),
        actions: <Widget>[
          FlatButton(
            child: Text("DISCONNECT"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: serverStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Navigator.pop(context);
          }
          return snapshot.hasData
              ? MessageHandler(snapshot.data, context, widget.channel)
              : Container();
        },
      ),
    );
  }
}
