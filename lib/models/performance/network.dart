import 'dart:io';

class Network {
  final File _netFile = new File('/proc/net/dev');

  void update () async {
    final String network = await _netFile.readAsString();
  }
}