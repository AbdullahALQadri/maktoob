import 'package:url_launcher/url_launcher.dart';

/// Public legal pages served by the backend (`routes/web.php`). The text and
/// its versions are published by the team from the admin dashboard.
class LegalLinks {
  LegalLinks._();

  static const String privacyPolicy = 'https://maktoob.social/privacy-policy';
  static const String termsOfService = 'https://maktoob.social/terms-of-service';

  /// Opens [url] in the external browser, in [lang] (`ar` / `en`) when
  /// given. Failures are swallowed.
  static Future<void> open(String url, {String? lang}) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(
        lang == null ? uri : uri.replace(queryParameters: {'lang': lang}),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }
}
