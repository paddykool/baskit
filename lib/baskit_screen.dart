import 'package:baskit/models/baskit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'boxes.dart';
import 'models/baskit_db_manager.dart';
import 'models/item.dart';
import 'navigation/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class BaskitScreen extends StatelessWidget {
  final int baskitIndex;

  BaskitScreen({required this.baskitIndex});

  static Page page({LocalKey? key, required int baskitIndex}) => MaterialPage(
        key: key,
        child: BaskitScreen(baskitIndex: baskitIndex),
      );

  // late final Baskit baskit;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   // Get the basket from hive
  //   baskit = BaskitDBManager.getBaskitBox().get(int.parse(widget.baskitKey));
  //   // baskit = Boxes.getBaskits().get(0)!;
  // }

  @override
  Widget build(BuildContext context) {
    final baskitDBManager =
        Provider.of<BaskitDBManager>(context, listen: false);

    // Set the current Baskit
    baskitDBManager.setCurrentBaskit(baskitIndex);
    final Baskit currentBaskit = baskitDBManager.getBaskit(baskitIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentBaskit.title} Item Screen'),
      ),
      body: BuildItemCardList(baskitIndex: baskitIndex),
    );
  }
}

class BuildItemCardList extends StatelessWidget {
  final int baskitIndex;

  BuildItemCardList({required this.baskitIndex});

  @override
  Widget build(BuildContext context) {
    final baskitDBManager = Provider.of<BaskitDBManager>(context, listen: true);

    final int currentBaskitIndex = baskitDBManager.getCurrentBaskit();
    final Baskit currentBaskit = baskitDBManager.getBaskit(currentBaskitIndex);

    // Get the list of items from the baskit
    List<Item> items = currentBaskit.itemsList;

    if (items.isEmpty) {
      return Center(
        child: Text('No items yet'),
      );
    } else {
      return Column(
        children: [
          // TODO - clear the whole list - probably not needed
          // ElevatedButton(
          //   onPressed: () {
          //     // TODO Fuck
          //   },
          //   child: Text('Clear list'),
          // ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                // final item = items[index];
                return ItemCard(itemIndex: index);
              },
            ),
          )
        ],
      );
    }
  }
}

Future<void> clearItemBox() async {
  print('inside clearItemBox()');
  // TODO - clear down the list<item> in the baskit
  // final box = Boxes.getItems();
  // await box.clear();
}

class ItemCard extends StatelessWidget {
  final int itemIndex;

  ItemCard({required this.itemIndex});

  void _openURL(String url) async {
    if (!await launch(url, forceSafariVC: false)) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    final baskitDBManager =
        Provider.of<BaskitDBManager>(context, listen: false);

    final int currentBaskitIndex = baskitDBManager.getCurrentBaskit();
    final Baskit currentBaskit = baskitDBManager.getBaskit(currentBaskitIndex);

    final Item item = currentBaskit.itemsList[itemIndex];

    return Card(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            final url = item.url;
            _openURL(url);
          },
          child: Image.network(
            item.imageURL,
            errorBuilder: (context, exception, stackTrace) {
              return Image.asset('assets/images/not_found.png');
            },
          ),
        ),
        title: GestureDetector(
          onTap: () {
            final url = item.url;
            _openURL(url);
          },
          child: Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: GestureDetector(
          onTap: () {
            final url = item.url;
            _openURL(url);
          },
          child: Text(item.price + "   " + item.host),
        ),
        trailing: GestureDetector(
          onTap: () {
            // TODO Remove the item from the list<items>
            baskitDBManager.deleteItemFromBaskit(itemIndex);
          },
          child: Icon(Icons.delete),
        ),
      ),
    );
  }
}
