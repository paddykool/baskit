import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:baskit/models/app_state_manager.dart';
import 'package:baskit/models/baskit_db_manager.dart';
import 'package:baskit/models/baskit.dart';
import 'package:baskit/models/item.dart';
import 'package:baskit/navigation/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BaskitAdapter());
  Hive.registerAdapter(ItemAdapter());
  // await Hive.openBox<Baskit>('baskits');
  await BaskitDBManager.openBaskitBox();

  // initialise the shareURL properties
  // TODO try async await here
  await appStateManager.initialiseWasOpenedByShareLaunch();

  // setup the stream to listen to onResume
  appStateManager.initialiseResumedBySharingURL();

  // wait 4 seconds before setting isInitialised to true
  appStateManager.initialiseApp();

  runApp(BaskitApp());
}

class BaskitApp extends StatefulWidget {
  @override
  State<BaskitApp> createState() => _BaskitAppState();
}

class _BaskitAppState extends State<BaskitApp> {
  @override
  void initState() {
    super.initState();
    // Get all the data from hive DB and populate the list in the model
    baskitDBManager.populateBaskitList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateManager>(
          lazy: false,
          create: (BuildContext context) => appStateManager,
        ),
        ChangeNotifierProvider<BaskitDBManager>(
          lazy: false,
          create: (BuildContext context) => BaskitDBManager(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Baskit',
        debugShowCheckedModeBanner: false,
        routerDelegate: goRouter.routerDelegate,
        routeInformationParser: goRouter.routeInformationParser,
      ),
    );
  }

  @override
  void dispose() {
    Hive.box('baskits').close();
    appStateManager.closeShareURLStream();
    super.dispose();
  }
}
