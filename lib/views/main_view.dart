// ignore_for_file: overridden_fields, library_private_types_in_public_api

import 'package:chess_ouvertures/constants.dart';
import 'package:chess_ouvertures/database/database_helper.dart';
import 'package:chess_ouvertures/views/board_view.dart';
import 'package:chess_ouvertures/views/database_main_view.dart';
import 'package:chess_ouvertures/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/board.dart';
import 'openings/opening_main_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class MainView extends StatefulWidget {
  @override
  final Key key;
  const MainView({required this.key}): super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  Key _openingMainViewKey = UniqueKey();
  Color _selectedColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _getColor();
    _initializeDatabase();
  }

  Future<void> _getColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? color = prefs.getString('selected_color');
    if (color != null) {
      if (color == 'black'){
        setState(() {
          _selectedColor = lighterColor(getColor('black')[1]);
        });
      }
      else {
        setState(() {
          _selectedColor = lighterColor(getColor(color)[0]);
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0){
        _openingMainViewKey = UniqueKey();
      }
      _selectedIndex = index;
    });
  }

  Future<void> _initializeDatabase() async {
    await DatabaseHelper().database;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
          icon: const Icon(Icons.menu, color: Colors.white,),
          onPressed: () {
            _scaffoldKey.currentState!.openEndDrawer();
          },
        )]
      ),
      key: _scaffoldKey,
      endDrawer: const SettingsView(),
      bottomNavigationBar: BottomNavigationBar(

        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: _selectedColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesome.play),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Opening',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_thresholding_outlined),
            label: 'Database',
          ),
        ],
      ),
      body: Stack(
        children: [
          Offstage(
            offstage: _selectedIndex != 1,
            child: Navigator(
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) => OpeningMainView(key: _openingMainViewKey),
                );
              },
            ),
          ),
          Offstage(
            offstage: _selectedIndex != 0,
            child: Navigator(
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) => BoardView(board: Board()),
                );
              },
            ),
          ),
          Offstage(
            offstage: _selectedIndex != 2,
            child: Navigator(
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) => const DatabaseMainView(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
