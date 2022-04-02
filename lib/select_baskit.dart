import 'package:baskit/models/item.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'boxes.dart';
import 'models/app_state_manager.dart';
import 'models/baskit.dart';
import 'package:go_router/go_router.dart';

import 'models/baskit_db_manager.dart';

class SelectBaskit extends StatefulWidget {
  const SelectBaskit({Key? key}) : super(key: key);

  static Page page({LocalKey? key}) => MaterialPage(
        key: key,
        child: SelectBaskit(),
      );

  @override
  State<SelectBaskit> createState() => _SelectBaskitState();
}

class _SelectBaskitState extends State<SelectBaskit> {
  // // use this to get the text for a new Baskit
  // final myController = TextEditingController();
  //
  // @override
  // void dispose() {
  //   myController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final baskitDBManager =
        Provider.of<BaskitDBManager>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Baskit'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Show dialog to get the name of new Baskit
          // String? newBaskitName = await createBaskitDialog(context);
          await showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return EnterBaskitNameDialog();
              });

          String newBaskitName =
              Provider.of<BaskitDBManager>(context, listen: false)
                  .getNewBaskitName();
          // Get the new Item from the Data manager
          Item item = Provider.of<BaskitDBManager>(context, listen: false)
              .getStoredNewItem();

          // create the new baskit
          List<Item> itemList = [item];
          Baskit newBaskit = Baskit(title: newBaskitName, itemsList: itemList);
          var indexOfNewBaskit = await baskitDBManager.addBaskit(newBaskit);
          print(
              'This is the Int after creating the new empty Baskit: $indexOfNewBaskit');

          // Reset the shared launch properties in app state manager
          Provider.of<AppStateManager>(context, listen: false)
              .resetShareLaunchProperties();

          // Go to the item screen for this new baskit
          context.go('/baskit/$indexOfNewBaskit');
        },
      ),
      body: BaskitCardList(),
    );
  }
}

class BaskitCardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baskitDBManager =
        Provider.of<BaskitDBManager>(context, listen: false);

    if (baskitDBManager.baskitCount == 0) {
      return Center(
        child: Text(
            'No Baskits created yet. Please Create a new baskit using the button below'),
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

  @override
  Widget build(BuildContext context) {
    final baskitDBManager =
        Provider.of<BaskitDBManager>(context, listen: false);

    // get the baskit title
    String baskitTitle = baskitDBManager.getBaskit(index).title;

    return Card(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        onTap: () async {
          // Add the item to the Baskit at this index
          // Get the baskit at this index...
          await baskitDBManager.addNewItemToBaskit(index);

          // Reset the shared launch properties in app state manager
          Provider.of<AppStateManager>(context, listen: false)
              .resetShareLaunchProperties();

          context.go('/baskit/$index');
        },
        title: Text(
          baskitTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class EnterBaskitNameDialog extends StatefulWidget {
  const EnterBaskitNameDialog({Key? key}) : super(key: key);

  @override
  _EnterBaskitNameDialogState createState() => _EnterBaskitNameDialogState();
}

class _EnterBaskitNameDialogState extends State<EnterBaskitNameDialog> {
  // use this to get the text for a new Baskit
  late final TextEditingController textController;

  // error variable - TODO change this to invalid ?
  bool _validBaskitname = false;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void submit() {
    // Write the new name to the Data manager
    if (!_validBaskitname) {
      Provider.of<BaskitDBManager>(context, listen: false)
          .setNewBaskitName(textController.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter New Baskit Name'),
      // Text field with a submit button
      content: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Enter name of new Baskit',
          errorText: _validBaskitname ? 'Name cannot be empty' : null,
        ),
        controller: textController,
        // This is if the user hits return on the keyboard
        // This should call a function - the same function
        // as onPressed for submit button
        // TODO add the below
        onSubmitted: (_) {
          setState(() {
            textController.text.isEmpty
                ? _validBaskitname = true
                : _validBaskitname = false;
          });
          if (!_validBaskitname) {
            submit();
          }
        },
      ),
      actions: [
        TextButton(
            child: Text('Submit'),
            onPressed: () {
              setState(() {
                textController.text.isEmpty
                    ? _validBaskitname = true
                    : _validBaskitname = false;
              });
              if (!_validBaskitname) {
                submit();
              }
            })
      ],
    );
  }
}

// // TODO - turn this into a class and put the Text controller inside it
// Future<String?> createBaskitDialog(BuildContext context) async {
//   String? newBaskitName;
//
//   await showDialog<String>(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Enter New Baskit Name'),
//         // Text field with a submit button
//         content: TextField(
//           autofocus: true,
//           decoration: InputDecoration(hintText: 'Enter name of new Baskit'),
//           // TODO Can the controller be inside of this 'createBaskitDialog' widget?
//           // Maybe if I make this widget a stateful widget???
//           controller: myController,
//
//           // This is if the user hits return on the keyboard
//           onSubmitted: (_) => null,
//         ),
//         actions: [
//           TextButton(
//             child: Text('Submit'),
//             // TODO - create a new baskit and return it's name
//             onPressed: () {
//               newBaskitName = myController.text;
//               Navigator.pop(context);
//             },
//           )
//         ],
//       );
//     },
//   );
//
//   // TODO - turn this whole thing into a class and
//   // write the name of the new baskit to a field in it.
//   return newBaskitName;
// }
