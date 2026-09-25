import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

typedef WhatsAppLauncher = Future<bool> Function(String number, {String? text});

/// Overridden in tests.
final whatsappProvider = Provider<WhatsAppLauncher>((ref) => openWhatsApp);

/// Opens a WhatsApp chat with [number] (international digits), optionally
/// with [text] typed in. Tries the installed app first, then wa.me in the
/// browser (which hands over to WhatsApp Desktop / Web). False if neither
/// could be opened.
Future<bool> openWhatsApp(String number, {String? text}) async {
  final encoded = text == null ? null : Uri.encodeComponent(text);
  final app = Uri.parse('whatsapp://send?phone=$number${encoded == null ? '' : '&text=$encoded'}');
  final web = Uri.parse('https://wa.me/$number${encoded == null ? '' : '?text=$encoded'}');
  try {
    if (await launchUrl(app, mode: LaunchMode.externalApplication)) return true;
  } catch (_) {
    // No app registered for whatsapp:// — fall back to the web link.
  }
  try {
    return await launchUrl(web, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
