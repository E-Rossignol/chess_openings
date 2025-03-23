import 'package:chess_ouvertures/views/database_main_view.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../constants.dart';
import '../database/database_helper.dart';

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
      backgroundColor: primaryThemeDarkColor,
      appBar: AppBar(
        backgroundColor: primaryThemeDarkColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DatabaseMainView(),
              ),
            );
          },
        ),
        title: const Text('Inspecteur de la base de données', style: TextStyle(color: Colors.white),),
      ),
      body: _tables.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
            child: Container(
                    width: MediaQuery.of(context).size.width / 2,
              child: ListView.builder(
                      itemCount: _tables.length,
                      itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal),
                ),
                child: ListTile(
                  title: Text(_tables[index]['name'], style: TextStyle(color: Colors.white),),
                  onTap: () async {
                    final data = await _database.rawQuery('SELECT * FROM ${_tables[index]['name']}');
                    Navigator.pushReplacement(
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
      backgroundColor: primaryThemeDarkColor,
      appBar: AppBar(
        backgroundColor: primaryThemeDarkColor,
        title: Text('Table: $tableName', style: TextStyle(color: Colors.white),),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: (){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DatabaseView(),
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
                child: Text(data[index].toString(), style: TextStyle(color: Colors.tealAccent),)),
          );
        },
      ),
    );
  }
}