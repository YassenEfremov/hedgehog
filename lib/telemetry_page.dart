import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class TelemetryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<AppState>();

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
