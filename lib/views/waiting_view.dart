import 'package:flutter/material.dart';

class WaitingView extends StatefulWidget {
  const WaitingView({super.key});

  @override
  State<WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends State<WaitingView> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("Not implemented yet"),
          CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 2,
          ),
        ],
      ),
    );
  }
}
