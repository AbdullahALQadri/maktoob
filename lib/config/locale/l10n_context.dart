import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// The text for [key] in the current language, with `{name}` placeholders
  /// filled from [args].
  String tr(String key, [Map<String, Object> args = const {}]) {
    var text = AppLocalizations.of(this)?.translate(key) ?? key;
    args.forEach((name, value) => text = text.replaceAll('{$name}', '$value'));
    return text;
  }

  String get languageCode => Localizations.localeOf(this).languageCode;
}
