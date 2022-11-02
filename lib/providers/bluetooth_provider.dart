import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:synchronized/synchronized.dart';

class BluetoothProvider extends ChangeNotifier {
  //initializing variables
  late Timer _timer;
  bool _scanStarted = false;
  bool _isConnected = false;
  late List<BluetoothDevice> _allDevices = [];
  late BluetoothDevice? _connectedDevice;
  StreamSubscription<List<int>>? subscription = null;
  List<String> listenList = [];

  late List<BluetoothService> _services;
  late BluetoothCharacteristic _characteristic;

  bool _blueMinus = false;
  bool _bluePlus = false;
  bool _orangeMinus = false;
  bool _orangePlus = false;
  int _scoreOrange = 0;
  int _scoreBlue = 0;

  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

//getters

  bool get scanStarted => _scanStarted;
  bool get isConnected => _isConnected;
  List<BluetoothDevice> get allDevices => _allDevices;

  bool get blueMinus => _blueMinus;
  bool get bluePlus => _bluePlus;
  bool get orangeMinus => _orangeMinus;
  bool get orangePlus => _orangePlus;
  int get scoreOrange => _scoreOrange;
  int get scoreBlue => _scoreBlue;

  var lock = new Lock();

  Guid getServiceUuid() {
    if (Platform.isIOS) return Guid('FFE0');
    return Guid('0000ffe0-0000-1000-8000-00805f9b34fb');
  }

  Guid getCharacteristicUuid() {
    if (Platform.isIOS) return Guid('FFE1');
    return Guid('0000ffe1-0000-1000-8000-00805f9b34fb');
  }

  void startScan() async {
    removeAllDevices();
    flutterBlue.stopScan();

    bool permGranted = false;
    _scanStarted = true;

    final loc.Location location = loc.Location();

    if (Platform.isAndroid) {
      var permission = false;

      var locationPermission = await location.requestPermission();

      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect
      ].request();

      if (locationPermission == loc.PermissionStatus.granted &&
          statuses[Permission.bluetoothScan]!.isGranted &&
          statuses[Permission.bluetoothAdvertise]!.isGranted &&
          statuses[Permission.bluetoothConnect]!.isGranted) {
        permission = true;
      }

      if (permission == true) permGranted = true;
    } else if (Platform.isIOS) {
      permGranted = true;
    }
    debugPrint('$permGranted');

    if (permGranted) {
      flutterBlue.startScan(
          timeout: Duration(seconds: 4), withServices: [getServiceUuid()]);

      flutterBlue.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.name.startsWith("SG")) {
            if (_allDevices.every((item) => item.id != r.device.id)) {
              print('namerih te ${r.device}');

              _allDevices.add(r.device);
              notifyListeners();
            }
          }
        }
      });
    }
    notifyListeners();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    flutterBlue.stopScan();
    _scanStarted = false;

    print("Statusa mi e:  ${device.state}");

    print("Imam id s: ${device.id}");

    try {
      await device.connect();
    } catch (e) {
      if (e != 'already_connected') {
        print("Try again sorry");
      }
    }

    _services = await device.discoverServices();
    // flutterBlue.state.listen((event) async {
    //   if (event != BluetoothState.on) {
    //     print("Nema bluetooth");
    //     print(event);
    //     if (_isConnected) disconnect();
    //   }
    // });

    for (int i = 0; i < _services.length; i++) {
      var service = _services[i];

      if (service.uuid == getServiceUuid()) {
        for (int i = 0; i < service.characteristics.length; i++) {
          _characteristic = service.characteristics[i];
          try {
            if (_characteristic.uuid == getCharacteristicUuid()) {
              _connectedDevice = device;
              _isConnected = true;
              if (!_characteristic.isNotifying) {
                await _characteristic.setNotifyValue(true);
                var temp = _characteristic.isNotifying;
                print('Stream changed $temp');
                subscription = _characteristic.value.listen((data) async {
                  print('Data recveived $data');
                  // sum = data[0] + data[1] + data[2];
                  if (data.length > 0) onDataReceived(data);
                });
              }
              notifyListeners();
              break;
            }
          } catch (e) {
            print(e);
          }
        }
      }
    }

    keepAlive();
    // device.state.listen(
    //   (event) async {
    //     print(event);
    //     switch (event) {
    //       case BluetoothDeviceState.connected:
    //         {
    //         
    //           break;
    //         }
    //       case BluetoothDeviceState.disconnected:
    //         try {
    //         
    //         } on Exception catch (e) {
    //          
    //         }
    //         break;

    //       case BluetoothDeviceState.connecting:
    //         print("Svurzvam se gosho ${event}");

    //         break;

    //       case BluetoothDeviceState.disconnecting:
    //       
    //         break;
    //       default:
    //         {
    //           print("Shto ne raboti ${event}");
    //         }
    //     }
    //   },
    // );

    notifyListeners();
  }


  void disconnect() async {
    _timer.cancel();
    await subscription?.cancel();
    _isConnected = false;
    _connectedDevice?.disconnect();
    _scanStarted = false;
    _allDevices = [];
    _services = [];

    print(subscription);

    notifyListeners();
  }

  void onDataReceived(data) {
    var sum = data[0] + data[1] + data[2];
    print('Data received:$sum');
    switch (sum) {
      case 76:
        {
          resetBooleans();
          _orangePlus = true;
        }
        break;
      case 77:
        {
          resetBooleans();
          _bluePlus = true;
        }
        break;
      case 78:
        {
          resetBooleans();
          _orangeMinus = true;
        }
        break;
      case 79:
        {
          resetBooleans();
          _blueMinus = true;
        }
        break;
      case 116:
        {
          resetBooleans();
          _scoreOrange += 1;
        }
        break;
      case 117:
        {
          resetBooleans();
          _scoreBlue += 1;
        }
        break;
    }

    notifyListeners();
  }

  void keepAlive() {
    if (_isConnected == true) {
      Timer.periodic(const Duration(seconds: 3), (timer) {
        _timer = timer;
        if (_isConnected == true) {
          handleKeepAlive();
        }
      });
      notifyListeners();
    }
  }

  void resetBooleans() {
    _blueMinus = false;
    _bluePlus = false;
    _orangeMinus = false;
    _orangePlus = false;
  }

  void handleKeepAlive() async {
    print('Keep alive activated');
    var data = List<int>.generate(6, (index) => index + 1);
    data[0] = 32;
    data[1] = 108;
    data[2] = 0;
    data[3] = 0;
    data[4] = 0;
    data[5] = 47;

    try {
      _characteristic.write(data, withoutResponse: true);
      // await lock.synchronized(() async {
      //   await
      // });
    } catch (e) {
      print("eroor $e");
    }
  }

  void removeAllDevices() {
    _allDevices = [];
    notifyListeners();
  }
}
