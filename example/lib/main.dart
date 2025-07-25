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

class TableDemoPage extends StatelessWidget {
  const TableDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
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

    final headers = [
      HeaderItem(text: 'ID', value: 'id', filterable: true, align: 'start'),
      HeaderItem(text: 'Name', value: 'name', filterable: true, align: 'start'),
      HeaderItem(
          text: 'Birth Date',
          value: 'birth_date',
          align: 'start',
          width: '150px'),
      HeaderItem(text: 'Mother', value: 'mother', align: 'start'),
      HeaderItem(
          text: 'Next Appointment', value: 'next_appointment', align: 'start'),
      HeaderItem(
          text: 'Follow-up',
          value: 'follow_up',
          align: 'start',
          sortable: false),
    ];

    final items = List.generate(2000, (index) {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Easy Table Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: EasyTable(
          headers: headers,
          items: items,
          expanded: true,
          // loadingConfig: LoadingItem(
          //   enabled: true,
          //   message: 'Fetching users...',
          //   color: Colors.green,
          // ),
          showSelect: true,
          onSelectionChanged: (selectedItems) {
            print('Selected: ${selectedItems}');
          },
          rowStyleBuilder: (item, index) {
            return BoxDecoration(
              color: item['follow_up'] == 'Yes' ? Colors.green : Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            );
          },
          style: TableStyle(
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
                  const SizedBox(height: 8),
                  DataTable(
                    columns: const [
                      DataColumn(
                          label: Text('Field',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Value',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text('Birth Date')),
                        DataCell(Text(item['birth_date'] ?? '-')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Mother')),
                        DataCell(Text(item['mother'] ?? '-')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Next Appointment')),
                        DataCell(Text(item['next_appointment'] ?? '-')),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Follow-up')),
                        DataCell(Text(item['follow_up'] ?? '-')),
                      ]),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
