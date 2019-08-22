class ServerMessages {
  static const String CONNECT = "CONNECT";
  static const String GAME_READY = "GAME_READY";
  static const String QUEUE_FAILED = "QUEUE_FAILED";
  static const String QUEUE_TIMEOUT = "QUEUE_TIMEOUT";
  static const String QUEUE_WAIT = "QUEUE_WAIT";
  static const String SUCCESS = "SUCCESS";
}

class ClientMessages {
  static const String ACCEPT_GAME = "ACCEPT_GAME";
  static const String DECLINE_GAME = "DECLINE_GAME";
}

class ServerResponse {
  String message;
  String body;

  ServerResponse({this.message, this.body});

  factory ServerResponse.fromJSON(dynamic json) {
    return ServerResponse(message: json["message"], body: json["body"]);
  }
}
