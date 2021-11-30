import 'package:html/dom.dart'; // Contains DOM related classes for extracting data from elements
import 'package:collection/collection.dart';

Map<String, dynamic> getItemDetails({required Document document}) {
  Map<String, dynamic> data = {'title': '???', 'imageURL': '???', 'price': '???'};

  // Get the item name
  List<Element> h1s = document.getElementsByTagName('h1');
  print('Number of titles found: ${h1s.length}');
  if (h1s.length != 0) {
    print("title found: ${h1s[0].text.trim()}");
    data["title"] = h1s[0].text.trim();
  }

  // Get image through nodes....
  // var nodes = document.nodes;
  // print('length of nodelist ${nodes.length}');
  // nodes.forEach((element) {
  //   print('Element node type: ${element.nodeType}');
  //   print('does the node have childnren... ${element..hasChildNodes()}');
  //   print(element.)
  // });
  // Find the image URL
  var images = document.getElementsByTagName('img');
  print('Number of images found: ${images.length}');

  // // Find the image with the same alt as the title
  // // TODO add error condition here
  Element? productImage = images.firstWhereOrNull((image) {
    Map<Object, String> attributeMap = image.attributes;

    return attributeMap.containsKey('alt') &&
        attributeMap['alt'] != null &&
        attributeMap['alt']!.length > 10 &&
        attributeMap['alt']!.substring(0, 9) == data["title"].substring(0, 9);
  });

  // Now get the source value
  if (productImage != null) {
    print('now checking the source attribute of the productImage...');

    if (productImage.attributes.containsKey('src')) {
      String imageURL = productImage.attributes['src']!;
      // Account for Protocol Relative URL
      imageURL.startsWith('http')
          ? data['imageURL'] = imageURL
          : data['imageURL'] = 'https:' + imageURL; // Hoping that it's https...
      print('URL of source is: ${data['imageURL']}');
    } else {
      print('No src found in image????');
    }
  } else {
    print('productImage element wasn\'t found.......');
  }

  // Get Price
  String allText = document.body!.text;
  // TODO getting all text but would be better with innerHTML
  // TODO can't find innerHTML property.. but it is there....
  print('text length: ${allText.length}');

  // find the first element that has a '€' at the start
  final regex = RegExp(r'([\$|£|€]\d{1,6}\.\d{1,2})');
  final match = regex.firstMatch(allText);
  final matchedText = match?.group(0);
  if (matchedText != null) {
    data['price'] = matchedText;
    print('Price found: $matchedText');
  }

  return data;
}
