import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

// import './BackgroundCollectedPage.dart';
// import './BackgroundCollectingTask.dart';
// import './ChatPage.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';

import 'home_page/home_page.dart';
import 'telemetry_page/telemetry_page.dart';
import 'control_page/control_page.dart';

// import './helpers/LineChart.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  int currentPageIndex = 0;
  BluetoothDevice? selectedDevice;
  BluetoothConnection? connection;

  BluetoothDevice? getSelectedDevice() {
    return selectedDevice;
  }

  void setSelectedDevice(BluetoothDevice newDevice) {
    setState(() {
      selectedDevice = newDevice;
    });
  }

  BluetoothConnection? getConnection() {
    return connection;
  }

  void setConnection(BluetoothConnection newConnection) {
    setState(() {
      connection = newConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: currentPageIndex,
          children: [
            HomePage(getSelectedDevice, setSelectedDevice, getConnection, setConnection),
            TelemetryPage(getConnection),
            ControlPage(getConnection),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.monitor_heart),
              label: 'Telemetry',
            ),
            NavigationDestination(
              icon: Icon(Icons.gamepad),
              label: 'Control',
            ),
          ],
          selectedIndex: currentPageIndex,
          onDestinationSelected: (index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          height: 60,
        ),
      ),
    );
  }
}
