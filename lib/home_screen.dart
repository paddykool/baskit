import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'boxes.dart';
import 'models/baskit.dart';
import 'models/baskit_db_manager.dart';
import 'navigation/routes.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static Page page({LocalKey? key}) => MaterialPage(
        key: key,
        child: HomeScreen(),
      );

  @override
  Widget build(BuildContext context) {
    // Populate the BaskitDBManager's list of baskits from the Hive DB
    // TODO - take another look at this
    // TODO - if the app hot restarts or opens from paused then the list in the
    // TODO - data manager is not populated... and is empty even if Hive DB haas records
    // TODO - main init() doesn't get run again...
    // TODO - so maybe have populateBaskitList() run onResume() somewhere....
    final baskitDBManager =
        Provider.of<BaskitDBManager>(context, listen: false);
    baskitDBManager.populateBaskitList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Baskits Screen'),
      ),
      body: BaskitCardList(),

      // body: ValueListenableBuilder<Box<Baskit>>(
      //   valueListenable: BaskitDBManager.getBaskitBox().listenable(),
      //   builder: (context, box, _) {
      //     final baskits = box.values.toList().cast<Baskit>();
      //     return buildBaskitCardList(baskits);
      //   },
      // ),
    );
  }
}

class BaskitCardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO - Probably nicer to have consumer here
    final baskitDBManager = Provider.of<BaskitDBManager>(context, listen: true);

    if (baskitDBManager.baskitCount == 0) {
      return Center(
        child: Text('No Baskits created yet'),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: baskitDBManager.baskitCount,
              itemBuilder: (BuildContext context, int index) {
                return BaskitCard(index: index);
              },
            ),
          )
        ],
      );
    }
  }
}

class BaskitCard extends StatelessWidget {
  final int index;

  BaskitCard({required this.index});

  // TODO - maybe have consumer here.. not in the widget above
  @override
  Widget build(BuildContext context) {
    final baskitDBManager =
        Provider.of<BaskitDBManager>(context, listen: false);

    // get the baskit title
    String baskitTitle = baskitDBManager.getBaskit(index).title;

    return Card(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        onTap: () {
          // Set the current baskit to be the index of this baskit
          baskitDBManager.setCurrentBaskit(index);
          context.go('/baskit/$index');
        },
        title: Text(
          baskitTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: GestureDetector(
          onTap: () {
            // TODO Remove the item from the list<items>
            baskitDBManager.deleteBaskit(index);
          },
          child: Icon(Icons.delete),
        ),
      ),
    );
  }
}

// Future<void> clearItemBox() async {
//   print('inside clearItemBox()');
//   final box = Boxes.getItems();
//   await box.clear();
// }
