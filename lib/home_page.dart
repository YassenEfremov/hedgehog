import 'package:flutter/material.dart';
import 'package:bluez/bluez.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<BlueZDevice> devices = {};
  var client = BlueZClient();
  bool scanning = false;
  bool paired = false;
  bool connected = false;

  void pair(BlueZDevice device) async {
    var adapter = client.adapters[0];
    // await adapter.stopDiscovery();

    // Register agent to handle pairing requests.
    var agent = MyAgent();
    await client.registerAgent(agent);

    // Request that our agent is used.
    await client.requestDefaultAgent();

    if (device.paired) {
      print('Device ${device.address} already paired');
      await client.close();
      return;
    }

    device.propertiesChanged.listen((properties) async {
      if (device.paired) {
        print('Device ${device.address} successfully paired');
        await client.close();
        return;
      }
    });
    await device.pair();
  }

  void startScan() async {
    await client.connect();

    if (client.adapters.isEmpty) {
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

  void stopScan() async {
    var adapter = client.adapters[0];
    await adapter.stopDiscovery();
  }

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
                    if (!scanning) {
                      scanning = true;
                      startScan();
                    } else {
                      scanning = false;
                      stopScan();
                    }
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
                      ],
                    ),
                    onTap: () { pair(device); },
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
