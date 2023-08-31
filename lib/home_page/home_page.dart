import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:location/location.dart';
// import 'package:scoped_model/scoped_model.dart';

// import '../ChatPage.dart';
import 'pair_page.dart';
import 'connect_page.dart';

// import './helpers/LineChart.dart';


class HomePage extends StatefulWidget {
  final BluetoothConnection? Function() getConnection;
  final ValueChanged<BluetoothConnection?> setConnection;
  final BluetoothDevice? Function() getConnectedDevice;
  final ValueChanged<BluetoothDevice?> setConnectedDevice;

  HomePage(this.getConnection, this.setConnection,
           this.getConnectedDevice, this.setConnectedDevice);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  // int _discoverableTimeoutSecondsLeft = 0;

  // bool _autoAcceptPairingRequests = false;

  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        // _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var buttonStyle = Theme.of(context).colorScheme.copyWith(
    //   background: Colors.lightBlue.shade100,
    // );

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            SwitchListTile(
              title: const Text('Enable Bluetooth'),
              subtitle: _bluetoothState.isEnabled ?
                Text('$_name ($_address)')
              :
                null,
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value) {
                    await FlutterBluetoothSerial.instance.requestEnable();
                  } else {
                    await FlutterBluetoothSerial.instance.requestDisable();
                  }
                }
    
                future().then((_) {
                  setState(() {});
                });
              },
            ),
            // SwitchListTile(
            //   title: const Text('Auto-try specific pin when pairing'),
            //   subtitle: const Text('Pin 1234'),
            //   value: _autoAcceptPairingRequests,
            //   onChanged: (bool value) {
            //     setState(() {
            //       _autoAcceptPairingRequests = value;
            //     });
            //     if (value) {
            //       FlutterBluetoothSerial.instance.setPairingRequestHandler(
            //           (BluetoothPairingRequest request) {
            //         print("Trying to auto-pair with Pin 1234");
            //         if (request.pairingVariant == PairingVariant.Pin) {
            //           return Future.value("1234");
            //         }
            //         return Future.value(null);
            //       });
            //     } else {
            //       FlutterBluetoothSerial.instance
            //           .setPairingRequestHandler(null);
            //     }
            //   },
            // ),
            _bluetoothState.isEnabled ?
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(Colors.lightBlue.shade500),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Icon(Icons.explore),
                            SizedBox(height: 10),
                            const Text('Pair \nwith device', textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                      onPressed: () async {
                        await Location().requestService();
                        final BluetoothDevice? selectedDevice =
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return PairPage();
                              },
                            ),
                          );
                    
                        if (selectedDevice != null) {
                          print('Pair -> selected ${selectedDevice.address}');
                        } else {
                          print('Pair -> no device selected');
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: widget.getConnectedDevice() == null ?
                        ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.blueGrey.shade400),
                        )
                      :
                        null,
                      child: widget.getConnectedDevice() == null ?
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Icon(Icons.bluetooth_searching),
                            SizedBox(height: 10),
                              const Text('Connect \nto paired device', textAlign: TextAlign.center),
                            ],
                          ),
                        )
                        :
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Icon(Icons.bluetooth_connected),
                              Text('Connected to:\n${widget.getConnectedDevice()!.name}', textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      onPressed: () async {
                        final BluetoothDevice? selectedDevice =
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ConnectPage(widget.getConnection, widget.setConnection, widget.getConnectedDevice, widget.setConnectedDevice, checkAvailability: false);
                              },
                            ),
                          );
                      
                        if (selectedDevice != null) {
                          print('Connect -> selected ${selectedDevice.address}');
                        } else {
                          print('Connect -> no device selected');
                        }
                      },
                    ),
                  ],
                ),
              )
            :
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bluetooth_disabled, size: 100, color: Colors.black12),
                    SizedBox(height: 20),
                    Text('Enable Bluetooth to get started!'),
                  ],
                )
              )
          ],
        ),
      ),
    );
  }

  // void _startChat(BuildContext context, BluetoothDevice server) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) {
  //         return ChatPage(server: server);
  //       },
  //     ),
  //   );
  // }
}
