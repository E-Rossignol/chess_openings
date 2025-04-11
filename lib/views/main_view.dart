// ignore_for_file: overridden_fields, library_private_types_in_public_api

import 'package:chess_ouvertures/database/database_helper.dart';
import 'package:chess_ouvertures/helpers/constants.dart';
import 'package:chess_ouvertures/model/style_preferences.dart';
import 'package:chess_ouvertures/views/board_view.dart';
import 'package:chess_ouvertures/views/database/database_main_view.dart';
import 'package:chess_ouvertures/views/settings/settings_view.dart';
import 'package:flutter/material.dart';
import '../model/board.dart';
import 'opening_main_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'openings/global_opening_board_view.dart';

class MainView extends StatefulWidget {
  @override
  final Key key;
  final StylePreferences stylePreferences = StylePreferences();
  MainView({required this.key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  Key _openingMainViewKey = UniqueKey();
  final Key _globalOpeningViewKey = UniqueKey();
  Color _selectedColor = Colors.green;

  @override
  void initState() {
    super.initState();
    widget.stylePreferences.selectedColor.addListener(_updateColors);
    _loadColorsFromPrefs();
    _initializeDatabase();
  }

  void _loadColorsFromPrefs() {
    widget.stylePreferences.loadPreferences();
    setState(() {
      _selectedColor = StylePreferences().selectedColor.value[1];
    });
  }

  void _updateColors() {
    setState(
          () {
        _selectedColor = widget.stylePreferences.selectedColor.value[1];
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        _openingMainViewKey = UniqueKey();
      }
      _selectedIndex = index;
    });
  }
  @override
  void dispose() {
    widget.stylePreferences.selectedColor.removeListener(_updateColors);
    super.dispose();
  }

  Future<void> _initializeDatabase() async {
    await DatabaseHelper().database;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryThemeDarkColor, actions: [
        IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onPressed: () {
            _scaffoldKey.currentState!.openEndDrawer();
          },
        )
      ]),
      key: _scaffoldKey,
      endDrawer: const SettingsView(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: primaryThemeDarkColor,
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
            icon: Icon(Icons.account_tree_outlined),
            label: 'Global',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Openings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_sharp),
            label: 'Database',
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
                  builder: (context) =>
                      OpeningMainView(key: _openingMainViewKey),
                );
              },
            ),
          ),
          Offstage(
            offstage: _selectedIndex != 1,
            child: Navigator(
              onGenerateRoute: (routeSettings) {
                return MaterialPageRoute(
                  builder: (context) =>
                      GlobalOpeningBoardView(board: Board(), key: _globalOpeningViewKey),
                );
              },
            ),
          ),
          Offstage(
            offstage: _selectedIndex != 3,
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
