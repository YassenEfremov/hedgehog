import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../BluetoothDeviceListEntry.dart';


class ConnectPage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not available, they would be disabled from the selection.
  final BluetoothConnection? Function() getConnection;
  final ValueChanged<BluetoothConnection?> setConnection;
  final BluetoothDevice? Function() getConnectedDevice;
  final ValueChanged<BluetoothDevice?> setConnectedDevice;
  final bool checkAvailability;

  const ConnectPage(this.getConnection, this.setConnection,
                    this.getConnectedDevice, this.setConnectedDevice,
                    {this.checkAvailability = true});

  @override
  _ConnectPage createState() => _ConnectPage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _ConnectPage extends State<ConnectPage> {
  List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>.empty(growable: true);

  // Availability
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool _isDiscovering = false;

  _ConnectPage();

  @override
  void initState() {
    super.initState();

    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering) {
      _startDiscovery();
    }

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
                device,
                widget.checkAvailability
                    ? _DeviceAvailability.maybe
                    : _DeviceAvailability.yes,
              ),
            )
            .toList();
      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var _device = i.current;
          if (_device.device == r.device) {
            _device.availability = _DeviceAvailability.yes;
            _device.rssi = r.rssi;
          }
        }
      });
    });

    _discoveryStreamSubscription?.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List<BluetoothDeviceListEntry> list = devices
    //     .map((_device) => BluetoothDeviceListEntry(
    //         device: _device.device,
    //         rssi: _device.rssi,
    //         enabled: _device.availability == _DeviceAvailability.yes,
    //         onTap: () async {
    //           Navigator.of(context).pop(_device.device);
    //         },
    //       )
    //     ).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Select device'),
        actions: <Widget>[
          _isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: new EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.replay),
                  onPressed: _restartDiscovery,
                )
        ],
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (BuildContext context, index) {
          _DeviceWithAvailability result = devices[index];
          final device = result.device;
          final address = device.address;
          return BluetoothDeviceListEntry(
            device: device,
            rssi: result.rssi,
            onTap: () async {
              try {
                bool connected = false;
                if (device.isConnected) {
                  print('Disconnecting from $address...');
                  await widget.getConnection()!.finish();
                  widget.setConnection(null);
                  widget.setConnectedDevice(null);
                  print('Disconnecting from $address has succeeded');
                } else {
                  print('Connecting with $address...');
                  connected = await _connectToDevice(device);
                  print('Connecting with $address has ${connected ? 'succeeded' : 'failed'}.');
                }
                setState(() {
                  devices[devices.indexOf(result)] = _DeviceWithAvailability(
                    BluetoothDevice(
                      name: device.name ?? '',
                      address: address,
                      type: device.type,
                      isConnected: connected
                    ),
                    _DeviceAvailability.yes,
                    result.rssi
                  );
                });
                Navigator.of(context).pop(device);
              } catch (ex) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error occurred while bonding'),
                      content: Text(ex.toString()),
                      actions: <Widget>[
                        TextButton(
                          child: Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }

  Future<bool> _connectToDevice(BluetoothDevice device) {
    bool connected = false;
    BluetoothConnection.toAddress(device.address).then((connection) {
      print('Connected to the device');
      widget.setConnection(connection);
      widget.setConnectedDevice(device);
      connected = true;

      // setState(() {
      //   isConnecting = false;
      //   isDisconnecting = false;
      // });

      // _connection.input!.listen(_onDataReceived).onDone(() {
      //   // Example: Detect which side closed the connection
      //   // There should be `isDisconnecting` flag to show are we are (locally)
      //   // in middle of disconnecting process, should be set before calling
      //   // `dispose`, `finish` or `close`, which all causes to disconnect.
      //   // If we except the disconnection, `onDone` should be fired as result.
      //   // If we didn't except this (no flag set), it means closing by remote.
      //   if (isDisconnecting) {
      //     print('Disconnecting locally!');
      //   } else {
      //     print('Disconnected remotely!');
      //   }
      //   if (this.mounted) {
      //     setState(() {});
      //   }
      // });
    }).catchError((error) {
      print('Cannot connect, exception occurred');
      print(error);
    });
    return Future.value(connected);
  }
}
