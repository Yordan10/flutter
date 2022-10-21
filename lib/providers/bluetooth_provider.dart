import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;

class BluetoothProvider extends ChangeNotifier {
  //initializing variables
  bool _scanStarted = false;
  bool _isConnected = false;
  late List<DiscoveredDevice> _allDevices = [];
  late DiscoveredDevice _connectedDevice;

  late StreamSubscription<ConnectionStateUpdate> _connection;

  late StreamSubscription<DiscoveredDevice> _scanStream;

  late QualifiedCharacteristic _rxCharacteristic;
  bool _blueMinus = false;
  bool _bluePlus = false;
  bool _orangeMinus = false;
  bool _orangePlus = false;
  int _scoreOrange = 0;
  int _scoreBlue = 0;

  final flutterReactiveBle = FlutterReactiveBle();

//getters

  bool get scanStarted => _scanStarted;
  bool get isConnected => _isConnected;
  List<DiscoveredDevice> get allDevices => _allDevices;
  DiscoveredDevice get connectedDevice => _connectedDevice;
  StreamSubscription<DiscoveredDevice> get scanStream => _scanStream;

  QualifiedCharacteristic get rxCharacteristic => _rxCharacteristic;
  bool get blueMinus => _blueMinus;
  bool get bluePlus => _bluePlus;
  bool get orangeMinus => _orangeMinus;
  bool get orangePlus => _orangePlus;
  int get scoreOrange => _scoreOrange;
  int get scoreBlue => _scoreBlue;

  Uuid getServiceUuid() {
    if (Platform.isIOS) return Uuid.parse('FFE0');
    return Uuid.parse('0000ffe0-0000-1000-8000-00805f9b34fb');
  }

  Uuid getCharacteristicUuid() {
    if (Platform.isIOS) return Uuid.parse('FFE1');
    return Uuid.parse('0000ffe1-0000-1000-8000-00805f9b34fb');
  }

  void startScan() async {
    removeAllDevices();

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
      _scanStream = flutterReactiveBle
          .scanForDevices(withServices: [getServiceUuid()]).listen((device) {
        // if (device.name.startsWith()) {
        if (_allDevices.every((item) => item.id != device.id)) {
          print('namerih te $device');

          _allDevices.add(device);
          notifyListeners();
          // }
        }
      }, onError: (err) {
        print('vlizam v greshkata');
        debugPrint('$err');
      });
    }
    notifyListeners();
  }

  void disconnect() async {
    try {
      await _connection.cancel();
      _isConnected = false;

      _allDevices = [];

      notifyListeners();
    } on Exception catch (e, _) {
      print("Error disconnecting from a device");
    }
  }

  void connectToDevice(DiscoveredDevice device) {
    _scanStream.cancel();
    _isConnected = true;
    print('vlizaaaaaaaaam $_isConnected');

    _connection = flutterReactiveBle
        .connectToDevice(
            id: device.id, connectionTimeout: const Duration(seconds: 2))
        .listen((event) async {
      switch (event.connectionState) {
        case DeviceConnectionState.connected:
          {
            print(event.connectionState);
            _connectedDevice = device;

            _rxCharacteristic = QualifiedCharacteristic(
                characteristicId: getCharacteristicUuid(),
                serviceId: getServiceUuid(),
                deviceId: event.deviceId);

            keepAlive();
            flutterReactiveBle
                .subscribeToCharacteristic(rxCharacteristic)
                .listen((data) {
              var sum = data[0] + data[1] + data[2];
              // Uint8List data = Uint8List.fromList(event);
              print('Data received:$sum');
              onDataReceived(data);
            });

            break;
          }
        case DeviceConnectionState.disconnected:
          {
            _connection.cancel();
            _isConnected = false;

            break;
          }
        default:
      }
    });
    notifyListeners();
  }

  void onDataReceived(data) {
    var sum = data[0] + data[1] + data[2];
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
    print('$isConnected');
    if (_isConnected == true) {
      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_isConnected) {
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

  void handleKeepAlive() {
    print(isConnected);
    print('Keep alive activated');
    var data = List<int>.generate(6, (index) => index + 1);
    data[0] = 32;
    data[1] = 108;
    data[2] = 0;
    data[3] = 0;
    data[4] = 0;
    data[5] = 47;
    final characteristic = QualifiedCharacteristic(
        serviceId: getServiceUuid(),
        characteristicId: getCharacteristicUuid(),
        deviceId: _connectedDevice.id);

    flutterReactiveBle.writeCharacteristicWithoutResponse(characteristic,
        value: data);
  }

  void removeAllDevices() {
    _allDevices = [];
    notifyListeners();
  }
}
