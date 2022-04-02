import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:baskit/models/baskit.dart';

import 'item.dart';

// TODO change name to BaskitDataManager - and change file name as well.
class BaskitDBManager extends ChangeNotifier {
  // List used to hold the baskits taken from hive
  List<Baskit> _baskits = [];

  // Holds the baskit currenly being displayed
  late int _currentBaskit;

  // Temp area to store new Item while user selects of creates a baskit
  Item? _newItemToStore;

  // Temp area to hold the name of a new Baskit created by the user
  String? _newBaskitName;

  // Bring in the baskits from Hive
  void populateBaskitList() {
    var box = getBaskitBox();
    _baskits = box.values.toList().cast<Baskit>();
  }

  // Open the box
  static openBaskitBox() async {
    await Hive.openBox<Baskit>('baskits');
  }

  // TODO - call this from main dispose
  static closeBaskitBox() {}

  // Get the box to use it
  static Box<Baskit> getBaskitBox() {
    return Hive.box<Baskit>('baskits');
  }

  // Number of baskits
  int get baskitCount {
    return getBaskitBox().length;
  }

  // Call this when baskits are modified
  void refreshBaskitList() {
    var box = getBaskitBox();
    _baskits = box.values.toList().cast<Baskit>();
    // TODO - why is this throwing an error ?
    notifyListeners();
  }

  // TODO use a getter here ??
  // set the current basket index and
  Baskit getBaskit(baskitIndex) {
    return _baskits[baskitIndex];
  }

  // TODO use a setter here ???
  void setCurrentBaskit(baskitIndex) {
    _currentBaskit = baskitIndex;
  }

  // TODO use a getter ?
  int getCurrentBaskit() {
    return _currentBaskit;
  }

  // Remove an item from the list
  void deleteItemFromBaskit(int itemIndex) async {
    var box = getBaskitBox();
    List<Item> baskitItems = box.getAt(_currentBaskit)!.itemsList;
    baskitItems.removeAt(itemIndex);

    Baskit baskit = box.getAt(_currentBaskit)!;
    baskit.itemsList = baskitItems;
    await baskit.save();

    // TODO - Will this update the item list ??
    notifyListeners();
  }

  // Add the item stored in _newItemToStore to the baskit using index
  Future<void> addNewItemToBaskit(int baskitIndex) async {
    var box = getBaskitBox();
    Baskit baskit = box.getAt(baskitIndex)!;
    baskit.itemsList.insert(0, _newItemToStore!);

    await baskit.save();
    // TODO - Will this update the item list ??
    notifyListeners();
  }

  void deleteBaskit(int index) async {
    var box = getBaskitBox();
    await box.deleteAt(index);
    refreshBaskitList();
  }

  // Add new baskit to the box and return the index position
  Future<int> addBaskit(Baskit newBaskit) async {
    var box = getBaskitBox();
    await box.add(newBaskit);
    refreshBaskitList();

    // return the index of that key.....
    int indexOfNewBaskit = _baskits.indexOf(newBaskit);
    return indexOfNewBaskit;
  }

  // Store the new item in the Modal until the Baskit is selected
  void storeItemToDataManager(Item newItem) {
    _newItemToStore = newItem;
  }

  // Get the stored new item
  // TODO put some sort of check here - return an exception?
  Item getStoredNewItem() {
    return _newItemToStore!;
  }

  // Set the new Baskit name
  // TODO - use getters and setters maybe....
  void setNewBaskitName(String newBaskitName) {
    _newBaskitName = newBaskitName;
  }

  String getNewBaskitName() {
    return _newBaskitName!;
  }
}

final BaskitDBManager baskitDBManager = BaskitDBManager();
