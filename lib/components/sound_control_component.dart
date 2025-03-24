import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundControlComponent extends StatefulWidget {
  const SoundControlComponent({super.key});

  @override
  State<SoundControlComponent> createState() => _SoundControlComponentState();
}

class _SoundControlComponentState extends State<SoundControlComponent> {
  bool _isMuted = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMuted = _prefs!.getBool('isMuted') ?? false;
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _prefs!.setBool('isMuted', _isMuted);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: _toggleMute,
        icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white, size: 30));
  }
}
