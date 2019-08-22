import 'dart:convert';

import 'package:client/models/computer.dart';
import 'package:client/models/messages.dart';
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
  // int acceptTime;
  // int currentTime = 0;

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
              ? _streamRouter(snapshot, context)
              : Text("no messages");
        },
      ),
    );
  }

  Widget _streamRouter(AsyncSnapshot snapshot, BuildContext context) {
    var response = json.decode(snapshot.data);
    switch (response["message"]) {
      case ServerMessages.CONNECT:
        return Text("In Queue for ${response["body"]}",
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.display2);

      case ServerMessages.GAME_READY:
        // print(response["body"] is int);
        // acceptTime = response["body"];
        // Timer.periodic(new Duration(seconds: 1), (timer) {
        //   currentTime++;
        //   if (currentTime == acceptTime) {
        //     timer.cancel();
        //   }
        // });

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Text("Time Remaining: $currentTime"),
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Text(
                  "Game is Ready",
                  style: Theme.of(context).primaryTextTheme.display2,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ButtonTheme(
                    height: 80,
                    minWidth: 150,
                    child: RaisedButton(
                      color: Colors.red,
                      child: Text("DECLINE GAME"),
                      onPressed: () {
                        widget.channel.sink.add(ClientMessages.DECLINE_GAME);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  ButtonTheme(
                    height: 80,
                    minWidth: 150,
                    child: RaisedButton(
                      child: Text("ACCEPT GAME"),
                      onPressed: () {
                        widget.channel.sink.add(ClientMessages.ACCEPT_GAME);
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      case ServerMessages.SUCCESS:
        return Center(
          child: Text("You've Successfully Accepted The Game",
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.display2),
        );
      case ServerMessages.QUEUE_WAIT:
        return Center(
          child: Text("Waiting for Others to Accept",
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.display2),
        );
      case ServerMessages.QUEUE_TIMEOUT:
        return Center(
          child: Text("You Missed the Queue",
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.display2),
        );
      case ServerMessages.QUEUE_FAILED:
        return Center(
          child: Text("Not all players accepted the queue. Going Again",
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.display2),
        );
      default:
        return Center(child: CircularProgressIndicator());
    }
  }
}
