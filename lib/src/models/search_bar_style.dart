import 'package:flutter/material.dart';

class SearchBarStyle {
  final EdgeInsetsGeometry padding;
  final InputDecoration decoration;
  final TextStyle? textStyle;

  const SearchBarStyle({
    this.padding = const EdgeInsets.all(8.0),
    this.decoration = const InputDecoration(
      hintText: 'Search...',
      prefixIcon: Icon(Icons.search),
    ),
    this.textStyle,
  });
}
