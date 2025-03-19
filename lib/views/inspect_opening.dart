import 'package:chess_ouvertures/constants.dart';
import 'package:chess_ouvertures/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:chess_ouvertures/model/openings/opening.dart';
import 'package:chess_ouvertures/model/openings/opening_move.dart';

class InspectOpeningView extends StatefulWidget {
  final Opening opening;

  InspectOpeningView({super.key, required this.opening});

  @override
  State<InspectOpeningView> createState() => _InspectOpeningViewState();
}

class _InspectOpeningViewState extends State<InspectOpeningView> {
  List<OpeningMove> currentMoves = [];
  List<int> idHistory = [];

  @override
  void initState() {
    super.initState();
    // Commencez par les mouvements dont previousMoveId == -1
    currentMoves = widget.opening.moves
        .where((move) => move.previousMoveId == -1)
        .toList();
    List<String> strOpening = widget.opening.toStr();
    print(strOpening);
  }

  void _onMoveTap(OpeningMove move) {
    setState(() {
      idHistory.add(move.id);
      currentMoves = widget.opening.findNextMove(move) ?? [];
    });
  }

  void _onBackTap() {
    if (idHistory.isNotEmpty) {
      setState(() {
        idHistory.removeLast();
        if (idHistory.isEmpty) {
          currentMoves = widget.opening.moves
              .where((move) => move.previousMoveId == -1)
              .toList();
        } else {
          int previousId = idHistory.last;
          currentMoves = widget.opening.moves
              .where((move) => move.previousMoveId == previousId)
              .toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inspect Opening'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const MainView())),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _onBackTap,
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 200,
          height: MediaQuery.of(context).size.height,
          child: ListView.builder(
            itemCount: currentMoves.length,
            itemBuilder: (context, index) {
              final move = currentMoves[index];
              return ListTile(
                title: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.lightBlueAccent.withOpacity(0.5),
                    ),
                    child: Center(
                        child: Text('${move.from.toStr()} ${move.to.toStr()}'))),
                onTap: () => _onMoveTap(move),
              );
            },
          ),
        ),
      ),
    );
  }
}
