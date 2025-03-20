import 'package:chess_ouvertures/database/database_helper.dart';
import 'package:chess_ouvertures/views/board_view.dart';
import 'package:chess_ouvertures/views/database_main_view.dart';
import 'package:chess_ouvertures/views/settings_view.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  Key _openingMainViewKey = UniqueKey();

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0){
        _openingMainViewKey = UniqueKey();
      }
      if (index == 3) {
        _scaffoldKey.currentState?.openEndDrawer();
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
      key: _scaffoldKey,
      endDrawer: const SettingsView(),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings'
          ),
        ],
      ),
      body: Stack(
        children: [
          Offstage(
            offstage: _selectedIndex != 0,
            child: Navigator(
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) => OpeningMainView(key: _openingMainViewKey),
                );
              },
            ),
          ),
          Offstage(
            offstage: _selectedIndex != 1,
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
          Offstage(
            offstage: _selectedIndex != 3,
            child: Navigator(
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) => const SettingsView(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
