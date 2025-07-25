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
    final headers = [
      HeaderItem(
        text: 'Name',
        value: 'name',
        filterable: true,
        align: 'start',
      ),
      HeaderItem(
        text: 'Birth Date',
        value: 'birth_date',
        filterable: false,
        align: 'center',
        width: '150px',
      ),
      HeaderItem(
        text: 'Mother',
        value: 'mother',
        filterable: false,
        align: 'start',
      ),
      HeaderItem(
        text: 'Next Appointment',
        value: 'next_appointment',
        filterable: false,
        align: 'end',
      ),
      HeaderItem(
        text: 'Follow-up',
        value: 'follow_up',
        filterable: false,
        sortable: false,
        align: 'center',
      ),
    ];

    final items = [
      {
        'name': 'Michael Johnson',
        'birth_date': '1990-05-10',
        'mother': 'Sarah Johnson',
        'next_appointment': '2025-07-30',
        'follow_up': 'Yes',
      },
      {
        'name': 'Emily Clark',
        'birth_date': '1985-09-20',
        'mother': 'Linda Clark',
        'next_appointment': '2025-08-15',
        'follow_up': 'No',
      },
      {
        'name': 'David Thompson',
        'birth_date': '1992-12-03',
        'mother': 'Karen Thompson',
        'next_appointment': '2025-07-30',
        'follow_up': 'Yes',
      },
      {
        'name': 'Sophia Lewis',
        'birth_date': '1987-03-14',
        'mother': 'Barbara Lewis',
        'next_appointment': '2025-08-15',
        'follow_up': 'No',
      },
      {
        'name': 'James Anderson',
        'birth_date': '1995-04-22',
        'mother': 'Deborah Anderson',
        'next_appointment': '2025-07-30',
        'follow_up': 'Yes',
      },
      {
        'name': 'Olivia Walker',
        'birth_date': '1991-11-09',
        'mother': 'Brenda Walker',
        'next_appointment': '2025-08-15',
        'follow_up': 'No',
      },
      {
        'name': 'William Harris',
        'birth_date': '1989-06-18',
        'mother': 'Nancy Harris',
        'next_appointment': '2025-07-30',
        'follow_up': 'Yes',
      },
      {
        'name': 'Ava Robinson',
        'birth_date': '1986-10-25',
        'mother': 'Carol Robinson',
        'next_appointment': '2025-08-15',
        'follow_up': 'No',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Easy Table Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: EasyTable(
          headers: headers,
          items: items,
          expanded: true,
          rowStyleBuilder: (item, index) {
            return BoxDecoration(
              color: item['follow_up'] == 'Yes' ? Colors.green : Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            );
          },
          expandedBuilder: (item) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Details for: ${item['name']}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Field',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Value',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: [
                    DataRow(cells: [
                      const DataCell(Text('Birth Date')),
                      DataCell(Text(item['birth_date']?.toString() ?? '-')),
                    ]),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
