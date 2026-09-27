import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeNotifier = await LocaleNotifier.load();

  runApp(
    ChangeNotifierProvider.value(
      value: localeNotifier,
      child: const ConventionApp(),
    ),
  );
}
