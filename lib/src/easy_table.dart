import 'package:flutter/material.dart';
import 'models/header_item.dart';

class EasyTable extends StatefulWidget {
  final List<HeaderItem> headers;
  final List<Map<String, dynamic>> items;
  final bool expanded;
  final Widget Function(Map<String, dynamic> item)? expandedBuilder;
  final BoxDecoration Function(Map<String, dynamic> item, int index)?
      rowStyleBuilder;

  const EasyTable({
    super.key,
    required this.headers,
    required this.items,
    this.expanded = false,
    this.expandedBuilder,
    this.rowStyleBuilder,
  });

  @override
  State<EasyTable> createState() => _EasyTableState();
}

class _EasyTableState extends State<EasyTable> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  String? _sortKey;
  bool _ascending = true;
  String _filterText = '';
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.items.where((item) {
      return widget.headers.where((h) => h.filterable).any((h) {
        final value = item[h.value]?.toString().toLowerCase() ?? '';
        return value.contains(_filterText.toLowerCase());
      });
    }).toList();

    if (_sortKey != null) {
      filteredItems.sort((a, b) {
        final aVal = a[_sortKey]?.toString() ?? '';
        final bVal = b[_sortKey]?.toString() ?? '';
        return _ascending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
      });
    }

    return Column(
      children: [
        _buildSearchBar(),
        Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: _calculateTotalTableWidth(),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  const Divider(height: 1),
                  SizedBox(
                    width: _calculateTotalTableWidth(),
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Scrollbar(
                      controller: _verticalController,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: _verticalController,
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              _buildRow(filteredItems[index], index),
                              if (_expandedIndex == index)
                                _buildExpandedContent(filteredItems[index]),
                              const Divider(height: 1),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateTotalTableWidth() {
    double total = 0;
    for (var h in widget.headers) {
      if (h.width != null) {
        final clean = h.width!.replaceAll('px', '');
        final parsed = double.tryParse(clean);
        if (parsed != null) total += parsed;
      } else {
        total += 150;
      }
    }

    if (widget.expanded) {
      total += 48;
    }

    return total;
  }

  Widget _buildSearchBar() {
    final hasFilterable = widget.headers.any((h) => h.filterable);
    return hasFilterable
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => _filterText = value),
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildHeader() {
    return Row(
      children: [
        ...widget.headers.map((header) {
          final isSorted = _sortKey == header.value;
          final columnWidth = header.width != null
              ? double.tryParse(header.width!.replaceAll('px', '')) ?? 150.0
              : 150.0;

          return Container(
            width: columnWidth,
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: header.sortable
                  ? () => setState(() {
                        if (_sortKey == header.value) {
                          _ascending = !_ascending;
                        } else {
                          _sortKey = header.value;
                          _ascending = true;
                        }
                      })
                  : null,
              child: Row(
                mainAxisAlignment: _getAlignment(header.align),
                children: [
                  Expanded(
                    child: Text(
                      header.text,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (header.sortable)
                    Icon(
                      isSorted
                          ? (_ascending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward)
                          : Icons.unfold_more,
                      size: 16,
                    ),
                ],
              ),
            ),
          );
        }),
        if (widget.expanded)
          const SizedBox(
            width: 48,
            child: Text(''),
          ),
      ],
    );
  }

  Widget _buildRow(Map<String, dynamic> item, int index) {
    final decoration = widget.rowStyleBuilder?.call(item, index);

    return InkWell(
      onTap: widget.expanded
          ? () => setState(() {
                _expandedIndex = _expandedIndex == index ? null : index;
              })
          : null,
      child: Container(
        decoration: decoration,
        child: Row(
          children: [
            ...widget.headers.map((header) {
              final columnWidth = header.width != null
                  ? double.tryParse(header.width!.replaceAll('px', '')) ?? 150.0
                  : 150.0;

              return Container(
                width: columnWidth,
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: _getTextAlign(header.align),
                  child: Text(
                    item[header.value]?.toString() ?? '',
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              );
            }),
            if (widget.expanded)
              Container(
                width: 48,
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                child: Icon(
                  _expandedIndex == index
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(Map<String, dynamic> item) {
    if (widget.expandedBuilder != null) {
      return widget.expandedBuilder!(item);
    }
    return Container(
      width: double.infinity,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(12),
      child: const Text(
        'Expanded',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  MainAxisAlignment _getAlignment(String align) {
    switch (align) {
      case 'center':
        return MainAxisAlignment.center;
      case 'end':
        return MainAxisAlignment.end;
      default:
        return MainAxisAlignment.start;
    }
  }

  Alignment _getTextAlign(String align) {
    switch (align) {
      case 'center':
        return Alignment.center;
      case 'end':
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }
}
