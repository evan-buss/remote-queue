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
  @override
  Widget build(BuildContext context) {
    switch (widget.response.message) {
      case ServerMessages.CONNECT:
        return Text("In Queue for ${widget.response.body}",
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.display2);

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
