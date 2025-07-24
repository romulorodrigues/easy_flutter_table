class HeaderItem {
  final String text;
  final String value;
  final String align;
  final bool filterable;
  final bool sortable;
  final String? width;

  HeaderItem({
    required this.text,
    required this.value,
    this.align = 'start',
    this.filterable = false,
    this.sortable = true,
    this.width,
  });
}
