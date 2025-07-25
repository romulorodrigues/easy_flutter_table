import 'package:flutter/material.dart';

class TableStyle {
  final Color? backgroundColor;
  final bool striped;
  final EdgeInsetsGeometry? cellPadding;

  const TableStyle({
    this.backgroundColor,
    this.striped = false,
    this.cellPadding,
  });
}
