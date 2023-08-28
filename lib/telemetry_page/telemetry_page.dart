import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

import '../BackgroundCollectedPage.dart';
import '../BackgroundCollectingTask.dart';
import '../SelectBondedDevicePage.dart';

// import './helpers/LineChart.dart';


class TelemetryPage extends StatefulWidget {
  @override
  _TelemetryPage createState() => new _TelemetryPage();
}

class _TelemetryPage extends State<TelemetryPage> {

  BackgroundCollectingTask? _collectingTask;

  @override
  void dispose() {
    _collectingTask?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          ListTile(title: const Text('Multiple connections example')),
          ListTile(
            title: ElevatedButton(
              child: ((_collectingTask?.inProgress ?? false)
                  ? const Text('Disconnect and stop background collecting')
                  : const Text('Connect to start background collecting')),
              onPressed: () async {
                if (_collectingTask?.inProgress ?? false) {
                  await _collectingTask!.cancel();
                  setState(() {
                    /* Update for `_collectingTask.inProgress` */
                  });
                } else {
                  final BluetoothDevice? selectedDevice =
                      await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SelectBondedDevicePage(
                            checkAvailability: false);
                      },
                    ),
                  );

                  if (selectedDevice != null) {
                    await _startBackgroundTask(context, selectedDevice);
                    setState(() {
                      /* Update for `_collectingTask.inProgress` */
                    });
                  }
                }
              },
            ),
          ),
          ListTile(
            title: ElevatedButton(
              child: const Text('View background collected data'),
              onPressed: (_collectingTask != null)
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ScopedModel<BackgroundCollectingTask>(
                              model: _collectingTask!,
                              child: BackgroundCollectedPage(),
                            );
                          },
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startBackgroundTask(
    BuildContext context,
    BluetoothDevice server,
  ) async {
    try {
      _collectingTask = await BackgroundCollectingTask.connect(server);
      await _collectingTask!.start();
    } catch (ex) {
      _collectingTask?.cancel();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error occured while connecting'),
            content: Text("${ex.toString()}"),
            actions: <Widget>[
              new TextButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

