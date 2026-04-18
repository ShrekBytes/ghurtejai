import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App UI language (Bangla / English). Drives [MaterialApp.locale].
final appLocaleProvider = StateProvider<Locale>((ref) => const Locale('en'));
