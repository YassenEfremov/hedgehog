import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

// import './helpers/LineChart.dart';


class ControlPage extends StatefulWidget {
  @override
  _ControlPage createState() => new _ControlPage();
}

class _ControlPage extends State<ControlPage> {
  BluetoothConnection? connection;

  bool LEDon = false;
  double K1 = 0.0;
  double K2 = 0.0;
  double K3 = 0.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('K1: $K1'),
                  ElevatedButton(
                    onPressed: () => setState(() => K1 += 0.1),
                    child: Icon(Icons.keyboard_arrow_up),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => K1 -= 0.1),
                    child: Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  Text('K2: $K2'),
                  ElevatedButton(
                    onPressed: () => setState(() => K2 += 0.1),
                    child: Icon(Icons.keyboard_arrow_up),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => K2 -= 0.1),
                    child: Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
              SizedBox(width: 10),
              Column(
                children: [
                  Text('K3: $K3'),
                  ElevatedButton(
                    onPressed: () => setState(() => K3 += 0.001),
                    child: Icon(Icons.keyboard_arrow_up),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => K3 -= 0.001),
                    child: Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ],
          ),
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

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
