import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:scoped_model/scoped_model.dart';

// import './helpers/LineChart.dart';


class ControlPage extends StatefulWidget {
  final BluetoothConnection? Function() getConnection;
  // final ValueChanged<BluetoothConnection> setConnection;

  ControlPage(this.getConnection);

  @override
  _ControlPage createState() => _ControlPage();
}

class _ControlPage extends State<ControlPage> {
  bool LEDon = false;
  double K1 = 0.0;
  double K2 = 0.0;
  double K3 = 0.0;
  double K1_delta = 0.1;
  double K2_delta = 0.1;
  double K3_delta = 0.001;

  @override
  Widget build(BuildContext context) {
    if (widget.getConnection() == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_disabled),
            SizedBox(height: 20,),
            Text('Connect to a cubli to control it!')
          ],
        )
      );
    } else {
      return Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text('Yaw'),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Image.asset('images/polar_coord_system.png')
                ),
                Align(
                  alignment: Alignment.center,
                  child: AnimatedRotation(
                    turns: 365 * 24 * 60 * 60 / 12,
                    duration: Duration(days: 365),
                    // angle: 10 * (pi / 180),
                    child: Icon(Icons.hexagon, size: 200, color: Colors.black12)
                  )
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text('K1: ${K1.toStringAsFixed(1)}'),
                    ElevatedButton(
                      onPressed: () => setState(() => K1 += K1_delta),
                      child: Icon(Icons.keyboard_arrow_up),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => K1 -= K1_delta),
                      child: Icon(Icons.keyboard_arrow_down),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: '$K1_delta',
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10),
                Column(
                  children: [
                    Text('K2: ${K2.toStringAsFixed(1)}'),
                    ElevatedButton(
                      onPressed: () => setState(() => K2 += K2_delta),
                      child: Icon(Icons.keyboard_arrow_up),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => K2 -= K2_delta),
                      child: Icon(Icons.keyboard_arrow_down),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: '$K2_delta',
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10),
                Column(
                  children: [
                    Text('K3: ${K3.toStringAsFixed(3)}'),
                    ElevatedButton(
                      onPressed: () => setState(() => K3 += K3_delta),
                      child: Icon(Icons.keyboard_arrow_up),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => K3 -= K3_delta),
                      child: Icon(Icons.keyboard_arrow_down),
                    ),
                    SizedBox(
                      width: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: '$K3_delta',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            IconButton(
              onPressed: () => setState(() {
                LEDon = !LEDon;
                _sendMessage(LEDon ? '1' : '0');
              }),
              icon: LEDon ?
                Icon(Icons.power_settings_new, color: Color.fromRGBO(255, 0, 0, 1.0))
                :
                Icon(Icons.power_settings_new, color: Color.fromRGBO(0, 255, 0, 1.0)),
            ),
            Text('Toggle LED'),
          ],
        ),
      );
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      try {
        widget.getConnection()!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await widget.getConnection()!.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
