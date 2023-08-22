import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:bluez/bluez.dart';


void main() async {

  // var client = BlueZClient();
  // await client.connect();

  // if (client.adapters.isEmpty) {
  //   print('No Bluetooth adapters found');
  //   await client.close();
  //   return;
  // }
  // var adapter = client.adapters[0];

  // print('Searching for devices on ${adapter.name}...');
  // for (var device in client.devices) {
  //   print('  ${device.address} ${device.name}');
  // }
  // client.deviceAdded
  //     .listen((device) => print('  ${device.address} ${device.name}'));

  // await adapter.startDiscovery();

  // await Future.delayed(Duration(seconds: 5));

  // await adapter.stopDiscovery();

  // await client.close();

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Hedgehog',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue.shade900),
        ),
        home: MyHomePage(),
      ),
    );
  }
}


class MyAppState extends ChangeNotifier {
  // var current = WordPair.random();

  // void getNext() {
  //   current = WordPair.random();
  //   notifyListeners();
  // }

  // var favorites = <WordPair>[];

  // void toggleFavorite() {
  //   if (favorites.contains(current)) {
  //     favorites.remove(current);
  //   } else {
  //     favorites.add(current);
  //   }
  //   notifyListeners();
  // }
}


class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = TelemetryPage();
        break;
      case 1:
        page = ControlPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.monitor_heart),
                      label: Text('Telemetry'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.gamepad),
                      label: Text('Control'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}


class TelemetryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        children: [
          Angle(),
          RPM()
        ],
      ),
    );
  }
}


class Angle extends StatefulWidget {
  @override
  State<Angle> createState() => _AngleState();
}

class _AngleState extends State<Angle> {

  var angle = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    final angleStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onBackground,
      fontWeight: FontWeight.bold
    );

    return Card(
      color: theme.colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Angle',
            style: titleStyle,
          ),
          Text(
            '$angle deg',
            style: angleStyle,
          ),
        ],
      )
    );
  }
}


class RPM extends StatefulWidget {
  @override
  State<RPM> createState() => _RPMState();
}

class _RPMState extends State<RPM> {

  var rpm = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onBackground,
    );
    final RPMStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onBackground,
      fontWeight: FontWeight.bold
    );

    return Card(
      color: theme.colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Motor RPM',
            style: titleStyle,
          ),
          Text(
            '$rpm rpm',
            style: RPMStyle,
          ),
        ],
      )
    );
  }
}


class ControlPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    return Placeholder();
  }
}
