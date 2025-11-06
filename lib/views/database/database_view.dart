// ignore_for_file: use_build_context_synchronously

import 'package:chess_openings/views/database/database_main_view.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../helpers/constants.dart';
import '../../database/database_helper.dart';

class DatabaseView extends StatefulWidget {
  const DatabaseView({super.key});

  @override
  State<DatabaseView> createState() => _DatabaseViewState();
}

class _DatabaseViewState extends State<DatabaseView> {
  late Database _database;
  List<Map<String, dynamic>> _tables = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _database = await DatabaseHelper().database;
    _loadTables();
  }

  Future<void> _loadTables() async {
    final tables = await _database
        .rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
    tables.removeAt(0);
    tables.removeAt(1);
    setState(() {
      _tables = tables;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryThemeDarkColor,
      appBar: AppBar(
        backgroundColor: primaryThemeDarkColor,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DatabaseMainView(),
              ),
            );
          },
        ),
        title: const Text(
          'Inspect',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _tables.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: ListView.builder(
                  itemCount: _tables.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.teal),
                      ),
                      child: ListTile(
                        title: Text(
                          _tables[index]['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () async {
                          final data = await _database.rawQuery(
                              'SELECT * FROM ${_tables[index]['name']}');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TableView(
                                  tableName: _tables[index]['name'],
                                  data: data),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class TableView extends StatelessWidget {
  final String tableName;
  final List<Map<String, dynamic>> data;

  const TableView({required this.tableName, required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    if (tableName == 'opening_names') {
      for (var i = 0; i < data.length; i++) {
        data[i]['piece_color'] = null;
      }
    }
    return Scaffold(
      backgroundColor: primaryThemeDarkColor,
      appBar: AppBar(
        backgroundColor: primaryThemeDarkColor,
        title: Text(
          'Table: $tableName',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DatabaseView(),
              ),
            );
          },
        ),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal),
                ),
                child: Text(
                  data[index].toString(),
                  style: const TextStyle(color: Colors.tealAccent),
                )),
          );
        },
      ),
    );
  }
}
