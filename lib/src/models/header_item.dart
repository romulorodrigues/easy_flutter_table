import 'package:flutter/material.dart';

class HeaderItem {
  final String? text;
  final Widget? textWidget;
  final String value;
  final String align;
  final bool filterable;
  final bool sortable;
  final String? width;

  HeaderItem({
    this.text,
    this.textWidget,
    required this.value,
    this.align = 'start',
    this.filterable = false,
    this.sortable = true,
    this.width,
  });

  Widget get effectiveTextWidget =>
      textWidget ?? Text(text ?? '', overflow: TextOverflow.ellipsis);
}
