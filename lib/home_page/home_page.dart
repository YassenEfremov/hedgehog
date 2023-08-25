import 'package:flutter/material.dart';
import 'package:bluez/bluez.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<BlueZDevice> devices = {};
  var client = BlueZClient();
  bool scanning = false;

  Future<void> pair(BlueZDevice device) async {
    var adapter = client.adapters[0];
    // await adapter.stopDiscovery();

    // Register agent to handle pairing requests.
    var agent = MyAgent();
    await client.registerAgent(agent);

    // Request that our agent is used.
    await client.requestDefaultAgent();

    if (device.paired) {
      print('Device ${device.address} already paired');
      // await client.close();
      return;
    }

    device.propertiesChanged.listen((properties) async {
      if (device.paired) {
        print('Device ${device.address} successfully paired');
        // await client.close();
        return;
      }
    });
    await device.pair();
    setState(() {});
  }

  Future<void> startScan() async {
    setState(() {
      scanning = true;
    });
    await client.connect();

    if (client.adapters.isEmpty) {
      setState(() {
        scanning = false;
      });
      await client.close();
      return Future.error('No Bluetooth adapters found');
    }
    var adapter = client.adapters[0];

    client.deviceAdded
        .listen((device) {
          print('${device.address} ${device.name}');
          setState(() {
            devices.add(device);
          });
        });
    client.deviceRemoved
        .listen((device) => setState(() {
          devices.add(device);
          })
        );

    await adapter.startDiscovery();
  }

  Future<void> stopScan() async {
    setState(() {
      scanning = false;
    });
    var adapter = client.adapters[0];
    await adapter.stopDiscovery();
  }

  // Future<void> connect(BlueZDevice device) async {
  //   await device.connect();
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final addressStyle = theme.textTheme.titleMedium!.copyWith(
      color: theme.colorScheme.secondary,
    );
    final titleStyle = theme.textTheme.titleLarge!.copyWith(
      color: theme.colorScheme.onBackground,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Row(
              children: [
                Text('Available devices:', style: titleStyle),
                Expanded(child: SizedBox(width: 100)),
                IconButton(
                  icon: scanning ? Icon(Icons.stop) : Icon(Icons.refresh),
                  onPressed: () => setState(() {
                    scanning ? stopScan() : startScan();
                  }),
                ),
              ],
            ),
            SizedBox(height: 10),
            for (var device in devices)
              if (device.name.isNotEmpty)
                Card(
                  child: ListTile(
                    leading: Icon(Icons.bluetooth),
                    title: Row(
                      children: [
                        Text('${device.name}'),
                        SizedBox(width: 10),
                        Text('(${device.address})', style: addressStyle),
                        SizedBox(width: 10),
                        device.paired ?
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Icon(Icons.key),
                          )
                          :
                          SizedBox(
                            width: 0,
                            height: 30,
                          ),
                        device.connected ?
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Icon(Icons.bluetooth_connected),
                          )
                          :
                          SizedBox(
                            width: 0,
                            height: 30,
                          ),
                      ],
                    ),
                    onTap: () async {
                      if (!device.paired) {
                        await pair(device);
                      } else {
                        var services = device.gattServices;
                        if (services.isEmpty) {
                          print('No GATT services');
                          return;
                        }
                        print('Device ${device.alias}');
                        await device.connect();
                        for (var service in device.gattServices) {
                          print('  Service ${service.uuid}');
                          for (var characteristic in service.characteristics) {
                            String characteristicValue;
                            try {
                              characteristicValue = '${await characteristic.readValue()}';
                            } on BlueZNotPermittedException {
                              characteristicValue = '<write only>';
                            } on BlueZException catch (e) {
                              characteristicValue = '<${e.message}>';
                            } catch (e) {
                              characteristicValue = '<$e>';
                            }
                            print(
                                '    Characteristic ${characteristic.uuid} = $characteristicValue');
                            for (var descriptor in characteristic.descriptors) {
                              String descriptorValue;
                              try {
                                descriptorValue = '${await descriptor.readValue()}';
                              } on BlueZNotPermittedException {
                                descriptorValue = '<write only>';
                              } on BlueZException catch (e) {
                                descriptorValue = '<${e.message}>';
                              } catch (e) {
                                descriptorValue = '<$e>';
                              }
                              print('      Descriptor ${descriptor.uuid} = $descriptorValue');
                            }
                          }
                        }
                      }
                    },
                  ),
                ),
            SizedBox(height: 10),
            Center(
              child:
                scanning ?
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  )
                  :
                  SizedBox(
                    width: 30,
                    height: 30,
                  )
            ),
          ],
        ),
      // );

          //else if (snapshot.hasError) {
          //   return Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       const Icon(
          //         Icons.error_outline,
          //         color: Colors.red,
          //         size: 60,
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.only(top: 16),
          //         child: Text('Error: ${snapshot.error}'),
          //       ),
          //     ],
          //   );
          // } else {
          //   return Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       SizedBox(
          //         width: 60,
          //         height: 60,
          //         child: CircularProgressIndicator(),
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.only(top: 16),
          //         child: Text('Scanning for devices ...'),
          //       ),
          //     ],
          //   );
          // }
        // },
      ),
    );
  }
}


class MyAgent extends BlueZAgent {
  @override
  Future<BlueZAgentPinCodeResponse> requestPinCode(BlueZDevice device) async {
    return BlueZAgentPinCodeResponse.success('1234');
  }

  @override
  Future<BlueZAgentResponse> displayPinCode(
      BlueZDevice device, String pinCode) async {
    print('PinCode $pinCode');
    return BlueZAgentResponse.success();
  }

  @override
  Future<BlueZAgentPasskeyResponse> requestPasskey(BlueZDevice device) async {
    return BlueZAgentPasskeyResponse.success(1234);
  }

  @override
  Future<BlueZAgentResponse> displayPasskey(
      BlueZDevice device, int passkey, int entered) async {
    print('Passkey $passkey');
    return BlueZAgentResponse.success();
  }

  @override
  Future<BlueZAgentResponse> requestConfirmation(
      BlueZDevice device, int passkey) async {
    print('Confirmed with passkey $passkey');
    return BlueZAgentResponse.success();
  }
}
