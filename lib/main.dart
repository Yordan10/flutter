import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/providers/bluetooth_provider.dart';
import 'package:flutter_app/providers/todo_provider.dart';
import 'package:flutter_app/screens/bluetooth_screen.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/screens/camera_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => TodoProvider()),
    ChangeNotifierProvider(create: (_) => BluetoothProvider())
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 0;

  List<Widget> pages = const [HomePage(), CameraPage(), BluetoothPage()];

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutka'),
      ),
      body: pages[currentPage],
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(displayWidth * .05),
        height: displayWidth * .155,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
            borderRadius: BorderRadius.circular(50)),
        child: ListView.builder(
            itemCount: destinations.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
            itemBuilder: (context, index) => InkWell(
                  onTap: (() {
                    setState(() {
                      currentPage = index;
                      HapticFeedback.lightImpact();
                    });
                  }),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Stack(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastLinearToSlowEaseIn,
                      width: index == currentPage
                          ? displayWidth * .37
                          : displayWidth * .25,
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.fastLinearToSlowEaseIn,
                        height: index == currentPage ? displayWidth * .12 : 0,
                        width: index == currentPage ? displayWidth * .34 : 0,
                        decoration: BoxDecoration(
                            color: index == currentPage
                                ? Colors.blueAccent.withOpacity(.3)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.fastLinearToSlowEaseIn,
                      width: index == currentPage
                          ? displayWidth * .37
                          : displayWidth * .24,
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.fastLinearToSlowEaseIn,
                                width: index == currentPage
                                    ? displayWidth * .15
                                    : 0,
                              ),
                              AnimatedOpacity(
                                opacity: index == currentPage ? 1 : 0,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.fastLinearToSlowEaseIn,
                                child: Text(index == currentPage
                                    ? destinations[index].label
                                    : ''),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  width: index == currentPage
                                      ? displayWidth * .05
                                      : 30),
                              Icon(listOfIcons[index],
                                  size: displayWidth * .076,
                                  color: index == currentPage
                                      ? Colors.blueAccent
                                      : Colors.black26)
                            ],
                          )
                        ],
                      ),
                    )
                  ]),
                )),
      ),
    );
  }

  List<NavigationDestination> destinations = [
    const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    const NavigationDestination(
        icon: Icon(Icons.photo_camera_outlined), label: 'Camera'),
    const NavigationDestination(
        icon: Icon(Icons.bluetooth), label: 'Bluetooth'),
  ];

  // List<String> listOfStrings = ['Home', 'Camera', 'Bluetooth'];
  List<IconData> listOfIcons = [Icons.home, Icons.camera_alt, Icons.bluetooth];
}
