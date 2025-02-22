import 'package:chess_ouvertures/views/main_view.dart';
import 'package:flutter/material.dart';

class OpeningView extends StatefulWidget {
  const OpeningView({super.key});

  @override
  State<OpeningView> createState() => _OpeningViewState();
}

class _OpeningViewState extends State<OpeningView> {
  List<String> openingsName = [];
  String? selectedOpening;

  @override
  void initState() {
    super.initState();
    openingsName.add("Cicilienne");
    openingsName.add("Système de Londres");
    openingsName.add("Défense française");
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration iconButtonDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.grey.shade200, Colors.grey.shade700],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    );
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 50
              ),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white,),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainView()),
                    );
                  },
                ),
              ),
            ],
          ),
          Opacity(
            opacity: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              child: Container(
                                decoration: iconButtonDecoration,
                                child: TextButton(
                                  onPressed: () {
                                    // Add your onPressed code here!
                                  },
                                  child: const Text("New opening", style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                  )),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Container(
                    decoration: iconButtonDecoration,
                    child: IntrinsicWidth(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  selectedOpening = null;
                                });
                              },
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.black,
                              )),
                          DropdownButton<String>(
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                            value: selectedOpening,
                            hint: Text("Select opening", style: TextStyle(color: Colors.grey.shade700)
                              ,),
                            items: openingsName.map((String opening) {
                              return DropdownMenuItem<String>(
                                value: opening,
                                child: Text(opening),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedOpening = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (selectedOpening != null)
                    SizedBox(
                      height: 30,
                      width: MediaQuery.of(context).size.width,
                    ),
                  if (selectedOpening != null)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              decoration: iconButtonDecoration,
                              child: IconButton(
                                onPressed: () {
                                  // Add your onPressed code here!
                                },
                                icon: const Icon(
                                  Icons.open_in_new_sharp,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              decoration: iconButtonDecoration,
                              child: IconButton(
                                onPressed: () {
                                  // Add your onPressed code here!
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              decoration: iconButtonDecoration,
                              child: IconButton(
                                onPressed: () {
                                  // Add your onPressed code here!
                                },
                                icon: const Icon(
                                  Icons.delete_outlined,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ]
      ),
    );
  }
}
