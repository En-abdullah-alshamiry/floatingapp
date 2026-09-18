import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_app/l10n/app_localizations.dart';

void main() {
  test('Arabic translations resolve', () {
    final l10n = AppLocalizations(const Locale('ar'));
    expect(l10n.tr('app_name'), 'بينا فلو');
    expect(l10n.tr('app_tagline'), 'أسلوبك... هويتك');
  });

  test('English translations resolve', () {
    final l10n = AppLocalizations(const Locale('en'));
    expect(l10n.tr('app_name'), 'BinaFlow');
    expect(l10n.tr('new_arrivals'), 'New Arrivals');
  });
}