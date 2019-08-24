import 'dart:convert';

import 'package:client/models/messages.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

/// [MessageHandler] builds Widgets based on the message returned by the websocket
///  server.
class MessageHandler extends StatefulWidget {
  final dynamic data;
  final BuildContext context;
  final IOWebSocketChannel channel;
  final ServerResponse response; // JSON decoded server response

  MessageHandler(this.data, this.context, this.channel)
      : this.response = ServerResponse.fromJSON(json.decode(data));

  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  Widget _messageCard(String message, {String subMessage}) {
    return Center(
      child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 1, color: Colors.teal)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                message,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              subMessage.isNotEmpty
                  ? Text(
                      subMessage,
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
                      textAlign: TextAlign.center,
                    )
                  : Container(),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.response.message) {
      case ServerMessages.CONNECT:
        return _messageCard("In Queue ", subMessage: "${widget.response.body}");
      case ServerMessages.GAME_READY:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
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
        return _messageCard("Game Accepted", subMessage: "Hurry back...");
      case ServerMessages.QUEUE_WAIT:
        return _messageCard("You've Accepted the Queue",
            subMessage: "Waiting for others...u");
      case ServerMessages.QUEUE_TIMEOUT:
        return _messageCard("Queue Missed",
            subMessage: "Please return to computer.");
      case ServerMessages.QUEUE_FAILED:
        return _messageCard("Not Everyone Accepted",
            subMessage: "Waiting for the next one.");
      default:
        return Center(child: CircularProgressIndicator());
    }
  }
}
