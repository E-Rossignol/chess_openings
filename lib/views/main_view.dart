import 'package:chess_ouvertures/database/database_helper.dart';
import 'package:chess_ouvertures/views/board_view.dart';
import 'package:chess_ouvertures/views/database_main_view.dart';
import 'package:flutter/material.dart';
import '../model/board.dart';
import 'openings/opening_main_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  final List<Widget> _views = [
    const OpeningView(),
    BoardView(board: Board()),
    const DatabaseMainView(),
  ];

  Future<void> _initializeDatabase() async {
    await DatabaseHelper().database;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Opening',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesome.play),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_thresholding_outlined),
            label: 'Database',
          ),
        ],
      ),
      body: _views[_selectedIndex],
    );
  }
}
