import 'package:flutter_app/providers/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<BluetoothProvider>(context);


    List<BluetoothDevice> allDevices =
        context.watch<BluetoothProvider>().allDevices;
    bool isConnected = context.watch<BluetoothProvider>().isConnected;

    return Scaffold(
      body: Column(
        children: [
          ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.all(10),
            children: allDevices.map((device) {
              return Row(
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(15),
                        color:
                            isConnected ? Colors.green[300] : Colors.red[600],
                        child: Text('${device.name} with id:${device.id}'),
                      )),
                  isConnected == false
                      ? Expanded(
                          flex: 2,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey, // background
                              ),
                              onPressed: (() {
                                context
                                    .read<BluetoothProvider>()
                                    .connectToDevice(device);
                              }),
                              child: const Icon(Icons.bluetooth)),
                        )
                      : Expanded(
                          flex: 2,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey, // background
                                // onPrimary: Colors.white, // foreground
                              ),
                              onPressed: (() {
                                context.read<BluetoothProvider>().disconnect();
                              }),
                              child: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              )),
                        ),
                ],
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  children: [
                    dataProvider.bluePlus == true
                        ? const Text(
                            "Blue plus is active",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 25),
                          )
                        : const Text(""),
                    Text("Blue team score: ${dataProvider.scoreBlue}"),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    dataProvider.orangePlus == true
                        ? const Text(
                            "Orange plus is active",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 25),
                          )
                        : const Text(""),
                    Text("Orange team score: ${dataProvider.scoreOrange}")
                  ],
                ),
              )
            ],
          )
        ],
      ),
      persistentFooterButtons: [
        isConnected
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.grey, onPrimary: Colors.white),
                onPressed: (() {
                   context.read<BluetoothProvider>().startScan();
                }),
                child: const Icon(Icons.search))
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.grey, onPrimary: Colors.white),
                onPressed: (() {
                  context.read<BluetoothProvider>().startScan();
                }),
                child: const Icon(Icons.search)),
      ],
    );
  }
}
