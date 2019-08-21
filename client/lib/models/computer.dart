class Computer {
  final String hostname;
  final String ip;
  final String port;

  Computer(this.hostname, this.ip, {this.port = "1337"});

  @override
  bool operator ==(other) {
    if (other is! Computer) {
      return false;
    }
    return hostname == other.hostname && ip == other.ip;
  }

  @override
  int get hashCode => hostname.hashCode ^ ip.hashCode ^ port.hashCode;
}