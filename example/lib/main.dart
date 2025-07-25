import 'dart:math';
import 'package:flutter/material.dart';
import 'package:easy_flutter_table/easy_flutter_table.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Flutter Table Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TableDemoPage(),
    );
  }
}

class TableDemoPage extends StatefulWidget {
  const TableDemoPage({super.key});

  @override
  State<TableDemoPage> createState() => _TableDemoPageState();
}

class _TableDemoPageState extends State<TableDemoPage> {
  bool _loading = true;
  late List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });

    final random = Random();
    final names = [
      'Alice',
      'Bob',
      'Charlie',
      'Diana',
      'Ethan',
      'Fiona',
      'George',
      'Hannah',
      'Ian',
      'Julia'
    ];
    final mothers = ['Mary', 'Susan', 'Linda', 'Patricia', 'Karen', 'Nancy'];
    final followUpOptions = ['Yes', 'No'];

    items = List.generate(2000, (index) {
      final id = index + 1;
      final name = '${names[random.nextInt(names.length)]} ${[
        'Smith',
        'Johnson',
        'Brown',
        'Taylor'
      ][random.nextInt(4)]}';
      final birthDate = DateTime(1970 + random.nextInt(30),
          1 + random.nextInt(12), 1 + random.nextInt(28));
      final appointmentDate =
          DateTime(2025, 7 + random.nextInt(2), 1 + random.nextInt(28));

      return {
        'id': id,
        'name': name,
        'birth_date':
            '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
        'mother': mothers[random.nextInt(mothers.length)],
        'next_appointment':
            '${appointmentDate.year}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}',
        'follow_up': followUpOptions[random.nextInt(2)],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final headers = [
      HeaderItem(text: 'ID', value: 'id', filterable: true, align: 'start'),
      HeaderItem(
          textWidget: Tooltip(
            message: 'Username',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.info, size: 16, color: Colors.black),
                SizedBox(width: 4),
                Text('Name'),
              ],
            ),
          ),
          value: 'name',
          filterable: true,
          align: 'start'),
      HeaderItem(
        text: 'Birth Date',
        value: 'birth_date',
        align: 'start',
        width: '150px',
      ),
      HeaderItem(
          text: 'Mother', value: 'mother', filterable: true, align: 'start'),
      HeaderItem(
          text: 'Next Appointment', value: 'next_appointment', align: 'start'),
      HeaderItem(
          textWidget: Tooltip(
            message: 'Follow-up',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text('Status'),
              ],
            ),
          ),
          value: 'follow_up',
          align: 'start',
          sortable: false),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Easy Flutter Table Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: EasyTable(
          headers: headers,
          items: items,
          primaryKey: 'id',
          expanded: true,
          searchBarStyle: SearchBarStyle(
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(Icons.filter_list),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            textStyle: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          loadingConfig: LoadingItem(
            enabled: _loading,
            message: 'Fetching users...',
            color: Colors.blue,
          ),
          showSelect: true,
          onSelectionChanged: (selectedItems) {
            print('Selected: $selectedItems');
          },
          // rowStyleBuilder: (item, index) {
          //   return BoxDecoration(
          //     color: item['follow_up'] == 'Yes' ? Colors.green : Colors.white,
          //     border: Border(
          //       bottom: BorderSide(color: Colors.grey.shade300),
          //     ),
          //   );
          // },
          style: const TableStyle(
            backgroundColor: Colors.white,
            striped: true,
            cellPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          ),
          expandedBuilder: (item) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details for: ${item['name']}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
          cellBuilder: (item, header) {
            if (header.value == 'birth_date') {
              final raw = item['birth_date'];
              if (raw == null || raw is! String) return const Text('-');
              final date = DateTime.tryParse(raw);
              if (date == null) return const Text('-');
              return Text(
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              );
            }

            if (header.value == 'mother') {
              final mother = item['mother'];
              return Text(
                '$mother',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            return Text(item[header.value]?.toString() ?? '');
          },
        ),
      ),
    );
  }
}
