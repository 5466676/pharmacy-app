import 'dart:math';

/// UUID version 7 (RFC 9562): 48-bit Unix-ms timestamp + random bits.
///
/// Ids sort by creation time (lexicographically, as strings), which the sync
/// engine relies on for cursors.
class UuidV7 {
  UuidV7({Random? random, DateTime Function()? clock})
    : _random = random ?? Random.secure(),
      _clock = clock ?? DateTime.now;

  final Random _random;
  final DateTime Function() _clock;

  int _lastMs = -1;
  int _seq = 0;

  /// Generates a new id. Within the same millisecond a 12-bit counter
  /// (`rand_a`) keeps ids from one generator strictly increasing.
  String generate() {
    var ms = _clock().toUtc().millisecondsSinceEpoch;
    if (ms <= _lastMs) {
      ms = _lastMs;
      _seq++;
      if (_seq > 0xFFF) {
        ms = ++_lastMs;
        _seq = 0;
      }
    } else {
      _seq = _random.nextInt(0x800); // leave headroom for increments
    }
    _lastMs = ms;

    final bytes = List<int>.filled(16, 0);
    for (var i = 0; i < 6; i++) {
      bytes[i] = (ms >> (8 * (5 - i))) & 0xFF;
    }
    bytes[6] = 0x70 | ((_seq >> 8) & 0x0F); // version 7
    bytes[7] = _seq & 0xFF;
    for (var i = 8; i < 16; i++) {
      bytes[i] = _random.nextInt(256);
    }
    bytes[8] = 0x80 | (bytes[8] & 0x3F); // RFC 9562 variant
    return _format(bytes);
  }

  /// Creation time encoded in a v7 id.
  static DateTime timestampOf(String id) {
    final hex = id.replaceAll('-', '').substring(0, 12);
    return DateTime.fromMillisecondsSinceEpoch(int.parse(hex, radix: 16), isUtc: true);
  }

  static final _pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  static bool isValid(String id) => _pattern.hasMatch(id);

  static String _format(List<int> b) {
    final hex = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
