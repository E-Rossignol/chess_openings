import 'package:flutter/material.dart';
import 'package:chess_openings/views/main_view.dart';
import '../views/welcome_view.dart';

/// Splash screen that animates an image and then navigates to the next view.
///
/// @param hasCode if true navigates to MainView, otherwise to WelcomeView
class SplashScreen extends StatefulWidget {
  final bool hasCode;
  const SplashScreen({super.key, required this.hasCode});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// Initializes animation controller and navigates when animation completes.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => widget.hasCode
                ? MainView(key: UniqueKey())
                : const WelcomeView(),
          ),
        );
      }
    });
  }

  /// Disposes the animation controller.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the splash screen with a scaling image.
  ///
  /// @param context build context
  /// @return Scaffold containing the animated image
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/images/splash_image.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
    );
  }
}
