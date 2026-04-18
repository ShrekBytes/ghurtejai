import 'package:flutter/material.dart';

import 'gj_palette.dart';

/// Legacy bold “Courier” styles. New screens should use [Theme.of(context).textTheme] where possible.
class GJText {
  static const _base = TextStyle(fontFamily: 'Courier', color: GJ.dark);

  static TextStyle display = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    height: 1.1,
  );
  static TextStyle title = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w900,
  );
  static TextStyle label = _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
  static TextStyle body = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static TextStyle tiny = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );
}
