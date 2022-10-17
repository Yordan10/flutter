import 'package:flutter/material.dart';

class LearnFlutterPage extends StatefulWidget {
  const LearnFlutterPage({super.key});

  @override
  State<LearnFlutterPage> createState() => _LearnFlutterPageState();
}

class _LearnFlutterPageState extends State<LearnFlutterPage> {
  bool isSwitch = false;
  bool? isCheck = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Flutka'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
              onPressed: (() {
                debugPrint('Actioni');
              }),
              icon: const Icon(Icons.info_outline))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Image.asset(
            'images/sashka.jpg',
            height: 350,
            width: double.infinity,
          ),
          const SizedBox(
            height: 5,
          ),
          const Divider(
            color: Colors.black,
          ),
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            color: Colors.blueGrey,
            width: double.infinity,
            child: const Center(
              child: Text(
                'Tova e sashko i obi4a da sere',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: isSwitch ? Colors.blue : Colors.green),
            onPressed: () {
              debugPrint('Elevated button');
            },
            child: const Text('Elevated button'),
          ),
          
          OutlinedButton(
            onPressed: () {
              debugPrint('Outlined button');
            },
            child: const Text('Outlined button'),
          ),
          TextButton(
            onPressed: () {
              debugPrint('Text button');
            },
            child: const Text('Text button'),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              debugPrint('Kuro mi qnko');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // mainAxisSize: MainAxisSize.max,
              children: const [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.blue,
                ),
                Text("Row widget"),
                Icon(
                  Icons.add_task,
                  color: Colors.blue,
                )
              ],
            ),
          ),
          Switch(
              value: isSwitch,
              onChanged: (bool newBool) {
                setState(() {
                  isSwitch = newBool;
                });
              }),
          Checkbox(
              value: isCheck,
              onChanged: ((bool? newBool) {
                setState(() {
                  isCheck = newBool;
                });
              })),
          Image.network(
              'https://w0.peakpx.com/wallpaper/333/363/HD-wallpaper-joker-cool-thumbnail.jpg')
        ]),
      ),
    );
  }
}
