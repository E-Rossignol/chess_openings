import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import 'main_view.dart';

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
    final tables = await _database.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
    setState(() {
      _tables = tables;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainView()));
          },
        ),
        title: const Text('Inspecteur de la base de données'),
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
                  border: Border.all(color: Colors.black),
                ),
                child: ListTile(
                  title: Text(_tables[index]['name']),
                  onTap: () async {
                    final data = await _database.rawQuery('SELECT * FROM ${_tables[index]['name']}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TableView(tableName: _tables[index]['name'], data: data),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Table: $tableName'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(data[index].toString()),
          );
        },
      ),
    );
  }
}