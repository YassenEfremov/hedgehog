import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

// import '../BackgroundCollectedPage.dart';
// import '../BackgroundCollectingTask.dart';
import '../SelectBondedDevicePage.dart';

// import './helpers/LineChart.dart';


class TelemetryPage extends StatefulWidget {
  final BluetoothConnection? Function() getConnection;
  // final ValueChanged<BluetoothConnection> setConnection;

  TelemetryPage(this.getConnection);

  @override
  _TelemetryPage createState() => new _TelemetryPage();
}

class _TelemetryPage extends State<TelemetryPage> {

  bool connected = false;
  String? rxData1;

  @override
  Widget build(BuildContext context) {
    if (widget.getConnection() == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_disabled),
            SizedBox(height: 20,),
            Text('Connect to a cubli to monitor it!')
          ],
        ),
      );
    } else {
      if (!connected) {
        // StreamController<Uint8List> s = StreamController<Uint8List>.broadcast();
        widget.getConnection()!.input!.listen(_onDataReceived).onDone(() {
          // Example: Detect which side closed the connection
          // There should be `isDisconnecting` flag to show are we are (locally)
          // in middle of disconnecting process, should be set before calling
          // `dispose`, `finish` or `close`, which all causes to disconnect.
          // If we except the disconnection, `onDone` should be fired as result.
          // If we didn't except this (no flag set), it means closing by remote.
          // if (isDisconnecting) {
          //   print('Disconnecting locally!');
          // } else {
          //   print('Disconnected remotely!');
          // }
          // if (this.mounted) {
          //   setState(() {});
          // }
        });
        setState(() {
          connected = true;
        });
      }

      return ListView(
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('$rxData1'),
            )
          ),

          // ListTile(title: const Text('Multiple connections example')),
          // ListTile(
          //   title: ElevatedButton(
          //     child: ((_collectingTask?.inProgress ?? false)
          //         ? const Text('Disconnect and stop background collecting')
          //         : const Text('Connect to start background collecting')),
          //     onPressed: () async {
          //       if (_collectingTask?.inProgress ?? false) {
          //         await _collectingTask!.cancel();
          //         setState(() {
          //           /* Update for `_collectingTask.inProgress` */
          //         });
          //       } else {
          //         final BluetoothDevice? selectedDevice =
          //             await Navigator.of(context).push(
          //           MaterialPageRoute(
          //             builder: (context) {
          //               return SelectBondedDevicePage(
          //                   checkAvailability: false);
          //             },
          //           ),
          //         );

          //         if (selectedDevice != null) {
          //           await _startBackgroundTask(context, selectedDevice);
          //           setState(() {
          //             /* Update for `_collectingTask.inProgress` */
          //           });
          //         }
          //       }
          //     },
          //   ),
          // ),
          // ListTile(
          //   title: ElevatedButton(
          //     child: const Text('View background collected data'),
          //     onPressed: (_collectingTask != null)
          //         ? () {
          //             Navigator.of(context).push(
          //               MaterialPageRoute(
          //                 builder: (context) {
          //                   return ScopedModel<BackgroundCollectingTask>(
          //                     model: _collectingTask!,
          //                     child: BackgroundCollectedPage(),
          //                   );
          //                 },
          //               ),
          //             );
          //           }
          //         : null,
          //   ),
          // ),
        ],
      );
    }
  }

  // Future<void> _startBackgroundTask(
  //   BuildContext context,
  //   BluetoothDevice server,
  // ) async {
  //   try {
  //     _collectingTask = await BackgroundCollectingTask.connect(server);
  //     await _collectingTask!.start();
  //   } catch (ex) {
  //     _collectingTask?.cancel();
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Error occured while connecting'),
  //           content: Text("${ex.toString()}"),
  //           actions: <Widget>[
  //             new TextButton(
  //               child: new Text("Close"),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    setState(() {
      rxData1 = dataString;
    });

    // int index = buffer.indexOf(13);
    // if (true) {  // original: (~index != 0) ????????????
    //   setState(() {
    //     messages.add(
    //       _Message(
    //         1,
    //         backspacesCounter > 0
    //             ? _messageBuffer.substring(
    //                 0, _messageBuffer.length - backspacesCounter)
    //             : _messageBuffer + dataString.substring(0, index),
    //       ),
    //     );
    //     _messageBuffer = dataString.substring(index);
    //   });
    // } else {
    //   _messageBuffer = (backspacesCounter > 0
    //       ? _messageBuffer.substring(
    //           0, _messageBuffer.length - backspacesCounter)
    //       : _messageBuffer + dataString);
    // }
  }
}

