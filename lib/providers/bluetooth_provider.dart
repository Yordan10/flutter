import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;

class BluetoothProvider extends ChangeNotifier {
  bool _scanStarted = false;
  bool _isConnected = false;
  late List<DiscoveredDevice> _allDevices = [];
  late DiscoveredDevice _connectedDevice;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late QualifiedCharacteristic _rxCharacteristic;

  final flutterReactiveBle = FlutterReactiveBle();

  bool get scanStarted => _scanStarted;
  bool get isConnected => _isConnected;
  List<DiscoveredDevice> get allDevices => _allDevices;
  DiscoveredDevice get connectedDevice => _connectedDevice;
  StreamSubscription<ConnectionStateUpdate> get connection => _connection;
  StreamSubscription<DiscoveredDevice> get scanStream => _scanStream;
  QualifiedCharacteristic get rxCharacteristic => _rxCharacteristic;

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

  void connectToDevice(DiscoveredDevice device) {
    _scanStream.cancel();
    
    Stream<ConnectionStateUpdate> currentConnectionStatus =
        flutterReactiveBle.connectToDevice(
            id: device.id, connectionTimeout: const Duration(seconds: 2));

    currentConnectionStatus.listen((event) async {
      switch (event.connectionState) {
        case DeviceConnectionState.connected:
          {
            _connectedDevice = device;
            _isConnected = true;

            _rxCharacteristic = QualifiedCharacteristic(
                characteristicId: getCharacteristicUuid(),
                serviceId: getServiceUuid(),
                deviceId: event.deviceId);

            keepAlive();
            flutterReactiveBle
                .subscribeToCharacteristic(rxCharacteristic)
                .listen((data) {
              // var sum = data[0] + data[1] + data[2];
              // Uint8List data = Uint8List.fromList(event);
              print('Data received:$data');
            });

            break;
          }
        case DeviceConnectionState.disconnected:
          {
            break;
          }
        default:
      }
    });
    notifyListeners();
  }

  void keepAlive() {
    Timer.periodic(const Duration(seconds: 5), (timer) => handleKeepAlive());
    notifyListeners();
  }

  void handleKeepAlive() {
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
