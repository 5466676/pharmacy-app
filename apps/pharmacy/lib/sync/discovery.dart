import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A Doaya server that answered on the local network.
class FoundServer {
  const FoundServer({required this.url, this.pharmacyName});
  final Uri url;
  final String? pharmacyName;

  @override
  bool operator ==(Object other) => other is FoundServer && other.url == url;
  @override
  int get hashCode => url.hashCode;
}

const discoveryPort = 47800;
const defaultHttpPort = 8000;

/// Asks the local network "DOAYA?" and collects answers for [timeout].
/// [target] is the broadcast address (tests use loopback).
Future<List<FoundServer>> discoverServers({
  Duration timeout = const Duration(seconds: 2),
  int port = discoveryPort,
  InternetAddress? target,
}) async {
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  socket.broadcastEnabled = true;
  final found = <FoundServer>{};
  final sub = socket.listen((event) {
    if (event != RawSocketEvent.read) return;
    final d = socket.receive();
    if (d == null) return;
    try {
      final j = jsonDecode(utf8.decode(d.data)) as Map<String, Object?>;
      if (j['service'] != 'doaya') return;
      final httpPort = (j['http_port'] as int?) ?? defaultHttpPort;
      found.add(
        FoundServer(
          url: Uri(scheme: 'http', host: d.address.address, port: httpPort, path: '/'),
          pharmacyName: j['pharmacy'] as String?,
        ),
      );
    } on FormatException {
      // Not ours.
    } on TypeError {
      // Not ours.
    }
  });
  final question = utf8.encode('DOAYA?');
  final to = target ?? InternetAddress('255.255.255.255');
  // Ask a few times: UDP on Wi-Fi drops packets.
  for (var i = 0; i < 3; i++) {
    socket.send(question, to, port);
    await Future<void>.delayed(timeout ~/ 3);
  }
  await sub.cancel();
  socket.close();
  return found.toList();
}

/// The server address typed by hand: "192.168.1.10", "192.168.1.10:8000"
/// or a full URL. Null when it can't be one.
Uri? parseServerAddress(String input) {
  var s = input.trim();
  if (s.isEmpty) return null;
  if (!s.contains('://')) s = 'http://$s';
  final u = Uri.tryParse(s);
  if (u == null || u.host.isEmpty) return null;
  return Uri(scheme: u.scheme, host: u.host, port: u.hasPort ? u.port : defaultHttpPort, path: '/');
}
