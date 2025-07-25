import 'package:flutter/material.dart';
import 'models/header_item.dart';
import 'models/loading_item.dart';
import 'models/search_bar_style.dart';
import 'models/table_style.dart';

class EasyTable extends StatefulWidget {
  final List<HeaderItem> headers;
  final List<Map<String, dynamic>> items;
  final bool expanded;
  final Widget Function(Map<String, dynamic> item)? expandedBuilder;
  final BoxDecoration Function(Map<String, dynamic> item, int index)?
      rowStyleBuilder;
  final LoadingItem loadingConfig;
  final bool showSelect;
  final void Function(List<Map<String, dynamic>> selectedItems)?
      onSelectionChanged;
  final TableStyle? style;
  final String primaryKey;
  final SearchBarStyle? searchBarStyle;

  const EasyTable({
    super.key,
    required this.headers,
    required this.items,
    this.expanded = false,
    this.expandedBuilder,
    this.rowStyleBuilder,
    this.loadingConfig = const LoadingItem(),
    this.showSelect = false,
    this.onSelectionChanged,
    this.style = const TableStyle(),
    required this.primaryKey,
    this.searchBarStyle,
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

  int _rowsPerPage = 10;
  int _currentPage = 0;

  final Set<dynamic> _selectedKeys = {};
  bool _selectAll = false;

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

  double _calculateMaxTableWidth() {
    final screenWidth = MediaQuery.of(context).size.width;
    final calculated = _calculateTotalTableWidth();
    return calculated < screenWidth ? screenWidth : calculated;
  }

  int _getFlex(HeaderItem header) {
    if (header.width != null) {
      final clean = header.width!.replaceAll('px', '');
      final parsed = double.tryParse(clean);
      if (parsed != null) return parsed.round();
    }
    return 150;
  }

  List<Map<String, dynamic>> _getFilteredAndSortedItems() {
    final filtered = widget.items.where((item) {
      return widget.headers.where((h) => h.filterable).any((h) {
        final value = item[h.value]?.toString().toLowerCase() ?? '';
        return value.contains(_filterText.toLowerCase());
      });
    }).toList();

    if (_sortKey != null) {
      filtered.sort((a, b) {
        final aVal = a[_sortKey];
        final bVal = b[_sortKey];

        if (aVal is num && bVal is num) {
          return _ascending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
        }

        final aStr = aVal?.toString() ?? '';
        final bStr = bVal?.toString() ?? '';
        return _ascending ? aStr.compareTo(bStr) : bStr.compareTo(aStr);
      });
    }

    return filtered;
  }

  List<Map<String, dynamic>> _getPaginatedItems(
      List<Map<String, dynamic>> items) {
    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    return items.sublist(start, end > items.length ? items.length : end);
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredAndSortedItems();
    final paginatedItems = _getPaginatedItems(filteredItems);
    final totalItemCount = filteredItems.length;

    final tableWidth = _calculateTotalTableWidth();
    final screenWidth = MediaQuery.of(context).size.width;
    final shouldScrollHorizontally = tableWidth > screenWidth;

    final tableContent = Container(
      color: widget.style?.backgroundColor,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          SizedBox(
            width: shouldScrollHorizontally ? tableWidth : screenWidth,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Scrollbar(
              controller: _verticalController,
              thumbVisibility: true,
              child: widget.loadingConfig.enabled
                  ? _buildLoading()
                  : ListView.builder(
                      controller: _verticalController,
                      itemCount: paginatedItems.length,
                      itemBuilder: (context, index) {
                        final actualIndex = _currentPage * _rowsPerPage + index;
                        return Column(
                          children: [
                            _buildRow(paginatedItems[index], actualIndex),
                            if (_expandedIndex == actualIndex)
                              _buildExpandedContent(paginatedItems[index]),
                            const Divider(height: 1),
                          ],
                        );
                      },
                    ),
            ),
          ),
          _buildFooter(totalItemCount),
        ],
      ),
    );

    return Column(
      children: [
        _buildSearchBar(),
        shouldScrollHorizontally
            ? Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: tableWidth),
                    child: tableContent,
                  ),
                ),
              )
            : tableContent,
      ],
    );
  }

  Widget _buildSearchBar() {
    final hasFilterable = widget.headers.any((h) => h.filterable);
    final style = widget.searchBarStyle ?? const SearchBarStyle();

    return hasFilterable
        ? Container(
            color: Colors.white,
            child: Padding(
              padding: style.padding,
              child: TextField(
                onChanged: (value) => setState(() => _filterText = value),
                decoration: style.decoration,
                style: style.textStyle,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildHeader() {
    return SizedBox(
      width: _calculateMaxTableWidth(),
      child: Row(
        children: [
          if (widget.showSelect)
            SizedBox(
              width: 48,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Checkbox(
                  value: _selectAll,
                  onChanged: (value) => setState(() {
                    _selectAll = value ?? false;
                    _selectedKeys.clear();
                    if (_selectAll) {
                      for (var item in widget.items) {
                        _selectedKeys.add(item[widget.primaryKey]);
                      }
                    }
                    widget.onSelectionChanged?.call(
                      widget.items
                          .where((i) =>
                              _selectedKeys.contains(i[widget.primaryKey]))
                          .toList(),
                    );
                  }),
                ),
              ),
            ),
          ...widget.headers.map((header) {
            final isSorted = _sortKey == header.value;
            final flex = _getFlex(header);

            return Flexible(
              flex: flex,
              child: Padding(
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
              ),
            );
          }),
          if (widget.expanded)
            const SizedBox(
              width: 48,
              child: Text(''),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> item, int index) {
    final baseDecoration = widget.rowStyleBuilder?.call(item, index);

    final isStriped = widget.style?.striped ?? false;
    final defaultColor =
        isStriped && index.isOdd ? Colors.grey.shade100 : Colors.transparent;

    final decoration = baseDecoration?.copyWith(
          color: baseDecoration.color ?? defaultColor,
        ) ??
        BoxDecoration(color: defaultColor);

    final itemKey = item[widget.primaryKey];

    return InkWell(
      onTap: widget.expanded
          ? () => setState(() {
                _expandedIndex = _expandedIndex == index ? null : index;
              })
          : null,
      child: Container(
        decoration: decoration,
        child: SizedBox(
          width: _calculateMaxTableWidth(),
          child: Row(
            children: [
              if (widget.showSelect)
                Container(
                  width: 48,
                  alignment: Alignment.center,
                  child: Checkbox(
                    activeColor: Colors.grey,
                    value: _selectedKeys.contains(itemKey),
                    onChanged: (value) => setState(() {
                      if (value == true) {
                        _selectedKeys.add(itemKey);
                      } else {
                        _selectedKeys.remove(itemKey);
                      }

                      _selectAll = _selectedKeys.length == widget.items.length;

                      widget.onSelectionChanged?.call(
                        widget.items
                            .where((i) =>
                                _selectedKeys.contains(i[widget.primaryKey]))
                            .toList(),
                      );
                    }),
                  ),
                ),
              ...widget.headers.map((header) {
                final flex = _getFlex(header);

                return Flexible(
                  flex: flex,
                  child: Padding(
                    padding:
                        widget.style?.cellPadding ?? const EdgeInsets.all(12),
                    child: Align(
                      alignment: _getTextAlign(header.align),
                      child: Text(
                        item[header.value]?.toString() ?? '',
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
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
      ),
    );
  }

  Widget _buildFooter(int totalItemCount) {
    if (widget.loadingConfig.enabled) {
      return const SizedBox.shrink();
    }

    final start = _currentPage * _rowsPerPage + 1;
    final end = (_currentPage + 1) * _rowsPerPage;
    final last = end > totalItemCount ? totalItemCount : end;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('Rows per page:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _rowsPerPage,
                items: [10, 25, 50].map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _rowsPerPage = value;
                      _currentPage = 0;
                    });
                  }
                },
              ),
            ],
          ),
          Row(
            children: [
              Text('$start - $last of $totalItemCount'),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: (_currentPage + 1) * _rowsPerPage < totalItemCount
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        LinearProgressIndicator(
          color: widget.loadingConfig.color,
        ),
        const SizedBox(height: 16),
        Text(
          widget.loadingConfig.message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ],
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
