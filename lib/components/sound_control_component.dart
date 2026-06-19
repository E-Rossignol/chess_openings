import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Component to control sound mute preference via an IconButton.
class SoundControlComponent extends StatefulWidget {
  const SoundControlComponent({super.key});

  @override
  State<SoundControlComponent> createState() => _SoundControlComponentState();
}

class _SoundControlComponentState extends State<SoundControlComponent> {
  bool _isMuted = false;
  SharedPreferences? _prefs;

  /// Loads saved preferences on init.
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  /// Retrieves SharedPreferences and reads the 'isMuted' preference.
  ///
  /// @return Future that completes when preferences are loaded
  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMuted = _prefs!.getBool('isMuted') ?? false;
    });
  }

  /// Toggles the muted state and persists it.
  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _prefs!.setBool('isMuted', _isMuted);
  }

  /// Builds the IconButton that represents mute/unmute.
  ///
  /// @param context build context
  /// @return IconButton widget
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: _toggleMute,
        icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white, size: 30));
  }
}
