import 'dart:ui';

import 'package:flutter/material.dart';

class LoadingItem {
  final bool enabled;
  final String message;
  final Color? color;

  const LoadingItem({
    this.enabled = false,
    this.message = 'Loading... Please wait',
    this.color = Colors.blue,
  });
}
