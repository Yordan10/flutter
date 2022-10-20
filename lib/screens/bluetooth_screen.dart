import 'package:flutter_app/providers/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  @override
  Widget build(BuildContext context) {
    bool scanStarted = context.watch<BluetoothProvider>().scanStarted;
    List<DiscoveredDevice> allDevices =
        context.watch<BluetoothProvider>().allDevices;
    bool isConnected = context.watch<BluetoothProvider>().isConnected;
    // void startScan = context.read<BluetoothProvider>().startScan();

    return Scaffold(
      body: Column(
        children: [
          ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.all(10),
            children: allDevices.map((device) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(15),
                      color: isConnected ? Colors.green[300] : Colors.red[600],
                      child: Text('${device.name} with id:${device.id}'),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey, // background
                          onPrimary: Colors.white, // foreground
                        ),
                        onPressed: (() => context
                            .read<BluetoothProvider>()
                            .connectToDevice(device)),
                        child: const Icon(Icons.bluetooth)),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
      persistentFooterButtons: [
        scanStarted || isConnected
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.grey, onPrimary: Colors.white),
                onPressed: (() {}),
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
