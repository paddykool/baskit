import 'package:baskit/models/item.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'boxes.dart';
import 'models/app_state_manager.dart';
import 'models/baskit.dart';
import 'package:go_router/go_router.dart';

class SelectBaskit extends StatefulWidget {
  final String title;
  final String imageURL;
  final String price;

  SelectBaskit(
      {required this.title, required this.imageURL, required this.price});

  static Page page(
          {LocalKey? key,
          required String title,
          required String imageURL,
          required String price}) =>
      MaterialPage(
        key: key,
        child: SelectBaskit(title: title, imageURL: imageURL, price: price),
      );

  @override
  State<SelectBaskit> createState() => _SelectBaskitState();
}

class _SelectBaskitState extends State<SelectBaskit> {
  // use this to get the text for a new Baskit
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Baskit'),
      ),
      // TODO - This will cause a popup to enter new Baskit Name
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Show shitty Dialog
          String? newBaskitName = await createBaskitDialog(context);

          // Create the Item
          Item item = Item(
            title: widget.title,
            imageURL: widget.imageURL,
            price: widget.price,
          );

          // create the new baskit
          List<Item> itemList = [item];
          Baskit newBaskit = Baskit(title: newBaskitName!, itemsList: itemList);
          var box = Boxes.getBaskits();
          int whatIsThisInt = await box.add(newBaskit);
          print(
              'This is the Int after creating the new empty Baskit: $whatIsThisInt');

          // Reset the shared launch properties in app state manager
          Provider.of<AppStateManager>(context, listen: false)
              .resetShareLaunchProperties();

          // Go to the item screen for this new baskit
          // I hope that this is actually the key for the baskit we just created
          context.go('/baskit/$whatIsThisInt');
        },
      ),
      body: ValueListenableBuilder<Box<Baskit>>(
        valueListenable: Boxes.getBaskits().listenable(),
        builder: (context, box, _) {
          final baskits = box.values.toList().cast<Baskit>();
          // return buildBaskitCardList(baskits);
          if (baskits.isEmpty) {
            return Center(
              child: Text(
                  'No Baskits created yet. Please use button to create a baskit'),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: baskits.length,
                    itemBuilder: (BuildContext context, int index) {
                      final baskit = baskits[index];
                      return Card(
                        margin: EdgeInsets.all(10.0),
                        child: ListTile(
                          // TODO - Save the item to this baskit
                          onTap: () {
                            // Create the item
                            Item item = Item(
                              title: widget.title,
                              imageURL: widget.imageURL,
                              price: widget.price,
                            );
                            //save the item to the Baskit
                            baskit.itemsList.add(item);
                            baskit.save();
                            // Reset the shared launch properties in app state manager
                            Provider.of<AppStateManager>(context, listen: false)
                                .resetShareLaunchProperties();
                            context.go('/baskit/${baskit.key}');
                          },
                          title: Text(
                            baskit.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }

  Future<String?> createBaskitDialog(BuildContext context) async {
    String? newBaskitName;

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter New Baskit Name'),
          // Text field with a submit button
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Enter name of new Baskit'),
            controller: myController,
            // TODO - create a new baskit and return it's name
            // This is if the user hits return on the keyboard
            onSubmitted: (_) => null,
          ),
          actions: [
            TextButton(
              child: Text('Submit'),
              // TODO - create a new baskit and return it's name
              onPressed: () {
                newBaskitName = myController.text;
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );

    return newBaskitName;
  }
}

// Widget buildBaskitCardList(List<Baskit> baskits) {
//   if (baskits.isEmpty) {
//     return Center(
//       child: Text('No Baskits created yet. Please use button to create a baskit'),
//     );
//   } else {
//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             scrollDirection: Axis.vertical,
//             shrinkWrap: true,
//             itemCount: baskits.length,
//             itemBuilder: (BuildContext context, int index) {
//               final baskit = baskits[index];
//               return BaskitCard(baskit: baskit);
//             },
//           ),
//         )
//       ],
//     );
//   }
// }

// class BaskitCard extends StatelessWidget {
//   final Baskit baskit;
//
//   BaskitCard({required this.baskit});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(10.0),
//       child: ListTile(
//         // TODO - Save the item to this baskit
//         onTap: () {
//
//         },
//         title: Text(
//           baskit.title,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     );
//   }
// }

// class _BaskitScreenState extends State<BaskitScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Baskit Item Screen'),
//       ),
//       body: ValueListenableBuilder<Box<Baskit>>(
//         valueListenable: Boxes.getBaskits().listenable(),
//         builder: (context, box, _) {
//           final baskits = box.values.toList().cast<Baskit>();
//           return buildBaskitCardList(baskits);
//         },
//       ),
//     );
//   }
// }
