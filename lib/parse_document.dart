import 'package:html/dom.dart'; // Contains DOM related classes for extracting data from elements
import 'package:collection/collection.dart';
import 'package:html/dom.dart';
import 'package:string_similarity/string_similarity.dart';

Map<String, dynamic> getItemDetails({
  required Document document,
  required String host,
  int? numH1s,
  int? h1Position,
  required Map<String, dynamic> allVisibleImages,
}) {
  Map<String, dynamic> data = {
    'title': '???',
    'imageURL': '???',
    'price': '???'
  };

  // IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE IMAGE
  // NEW PLAN!! - go though al the visible images and get
  // the image who's alt is most similar to the title
  // So first... get a list from the map

  List<ImageAttributes> imageList = allVisibleImages.values
      .map((value) => ImageAttributes(
            value["alt"],
            value["area"],
            value["currentSrc"],
            value["datasrc"],
            value["imageElementPosition"],
            value["src"],
          ))
      .toList();

  print(imageList);

  //  Now find the largest image
  ImageAttributes largestImage =
      imageList.reduce((curr, next) => curr.area >= next.area ? curr : next);

  print('alt property of largest visible Image Element: ${largestImage.alt}');
  print('src property of largest visible Image Element: ${largestImage.src}');

  // if src is empty - use current src
  String? rawImageUrl;
  if (largestImage.src != "") {
    rawImageUrl = largestImage.src;
  } else {
    rawImageUrl = largestImage.currentSrc;
  }

  // now add to data map
  print('final image url: $rawImageUrl');
  data['imageURL'] = rawImageUrl;

  // TITLE TITLE TITLE TITLE TITLE TITLE TITLE TITLE TITLE TITLE TITLE TITLE TITLE
  if (numH1s != 0) {
    String itemTitle;
    List<Element> h1s = document.getElementsByTagName('h1');
    if (h1Position != null) {
      // get the text of the first visible h1
      // Marks and Spencer mobile has title as first h1 (but it's not visible)
      if (host.contains('marksandspencer')) {
        itemTitle = h1s[0].text.replaceAll(RegExp(r"\s+"), " ").trim();
      } else {
        // continue as normal
        itemTitle = h1s[h1Position].text.replaceAll(RegExp(r"\s+"), " ").trim();
      }
    } else {
      itemTitle = h1s[0].text.replaceAll(RegExp(r"\s+"), " ").trim();
    }

    print('title: $itemTitle');
    data["title"] = itemTitle;
  } else {
    // If there are no h1's - use the alt from the image
    print('NO H1\'S IN HTML - using alt from image');
    print('title: ${largestImage.alt}');
    data["title"] = largestImage.alt;
  }

  // PRICE PRICE PRICE PRICE PRICE PRICE PRICE PRICE PRICE PRICE PRICE PRICE PRICE
  // OK so now we need the actual image element
  // Get the image element by the position of largest img

  // var imageElementPosition = largestImage.imageElementPosition

  Element actualImageElement = document
      .querySelectorAll('img')[largestImage.imageElementPosition.toInt()];

  // Then return the first text that has a € or £ symbol
  String textContainingPrice = getParentText(element: actualImageElement);

  // print('parentTextContainingPrice: $textContainingPrice');

  // find the first element that has a '€' or '£' or '$' at the start
  // Maybe needs firstmatchOrNull ??
  final regex = RegExp(r'[\$£€]\s*\d{1,6}([,|\.]\d{1,2})?');
  final match = regex.firstMatch(textContainingPrice);
  final matchedText = match?.group(0);
  if (matchedText != null) {
    data['price'] = matchedText;
    print('Price found: $matchedText');
  } else {
    print(
        'DEBUG DEBUG - NO PRICE FOUND!!! NO PRICE FOUND!!! NO PRICE FOUND!!! NO PRICE FOUND!!! ');
  }

  return data;
}

String getParentText({required Element element}) {
  String textThatContainsPrice = "";

  // Create a list of all the parent elements
  List<Element> parentElements = [];
  Element? parentElement = element.parent;
  while (parentElement != null) {
    parentElements.add(parentElement);
    parentElement = parentElement.parent;
  }

  // Now find the first element whose text contains 'a' price
  // TODO this is causing issue with ASOS - cannot find a firstwhere
  // Maybe needs firstwhereornull...
  final moneySymbolRegEx = RegExp(r'[\$£€]\s*\d{1,6}');
  Element? priceContainingElement = parentElements
      .firstWhereOrNull((element) => element.text.contains(moneySymbolRegEx));

  if (priceContainingElement == null) {
    return "Regular expression not found in all text...";
  }
  return priceContainingElement.text;
}

class ImageAttributes {
  final alt;
  final area;
  final currentSrc;
  final datasrc;
  final imageElementPosition;
  final src;

  ImageAttributes(
    this.alt,
    this.area,
    this.currentSrc,
    this.datasrc,
    this.imageElementPosition,
    this.src,
  );
}
