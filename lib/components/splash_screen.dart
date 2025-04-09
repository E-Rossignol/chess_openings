import 'package:chess_ouvertures/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chess_ouvertures/views/main_view.dart';
import '../views/welcome_view.dart';

class SplashScreen extends StatefulWidget {
  final bool hasCode;
  const SplashScreen({super.key, required this.hasCode});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialisation du lecteur vidéo
    _controller = VideoPlayerController.asset('assets/video/splash.mp4')
      ..initialize().then((_) {
        // Lecture automatique de la vidéo
        _controller.play();
        _controller.setLooping(false);
        // Redirection après la fin de la vidéo
        _controller.addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => widget.hasCode ? MainView(key: UniqueKey()): const WelcomeView()),
            );
          }
        });
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryThemeDarkColor,
      body: _controller.value.isInitialized
          ? Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}