import 'package:chess_ouvertures/components/sound_control_component.dart';
import 'package:chess_ouvertures/helpers/constants.dart';
import 'package:chess_ouvertures/views/settings/style_view.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: primaryThemeDarkColor,
      shadowColor: secondaryThemeDarkColor,
      width: 100,
      child: ListView(
        children: [
          const SizedBox(
            height: 60,
          ),
          const SoundControlComponent(),
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const StyleView()));
              },
              icon: const Icon(Icons.palette_outlined,
                  size: 30, color: Colors.white)),
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.language, size: 30)),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close_outlined, size: 30),
          ),
        ],
      ),
    );
  }
}
