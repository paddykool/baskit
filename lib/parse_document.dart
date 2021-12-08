import 'package:html/dom.dart'; // Contains DOM related classes for extracting data from elements
import 'package:collection/collection.dart';
import 'package:string_similarity/string_similarity.dart';

Map<String, dynamic> getItemDetails({required Document document}) {
  Map<String, dynamic> data = {'title': '???', 'imageURL': '???', 'price': '???'};

  // Get the item name
  List<Element> h1s = document.getElementsByTagName('h1');
  print('Number of h1s found: ${h1s.length}');

  if (h1s.length != 0) {
    print('h1 raw: ${h1s[0].text}');
    print('h1 with trim: ${h1s[0].text.trim()}');
    print("first h1 found: ${h1s[0].text.trim()}");
    String removeMultiSpace = h1s[0].text.replaceAll(RegExp(r"\s+"), " ");
    print('removeMultiSpace: $removeMultiSpace');
    data["title"] = removeMultiSpace.trim();
  }

  // Find the image URL
  var images = document.getElementsByTagName('img');
  print('Number of images found: ${images.length}');

  // --------------------------------------------------------------------------------
  //  Find the image element using ... shite
  //
  String itemTitle = data["title"];
  // Element altSimilarImage = images.reduce((curr, next) => curr.attributes['alt'].similarityTo(itemTitle) > next.attributes['alt'].similarityTo(itemTitle) ? curr : next);

  Element altSimilarImage = images.reduce((curr, next) {
    print('curr element alt text: ${curr.attributes['alt']}');
    print('curr element alt similar value: ${curr.attributes['alt'].similarityTo(itemTitle)}');
    print('next element alt text: ${next.attributes['alt']}');
    print('next element alt similar value: ${next.attributes['alt'].similarityTo(itemTitle)}');
    print('-----------------------');

    if (curr.attributes['alt'].similarityTo(itemTitle) >=
        next.attributes['alt'].similarityTo(itemTitle)) {
      return curr;
    } else {
      return next;
    }
  });

  print('alt property of Element from string similiar: ${altSimilarImage.attributes['alt']}');

  for (var image in images) {
    Map<Object, String> attributeMap = image.attributes;
    if (attributeMap.containsKey('alt')) {
      print('Image contains alt and value is: ${attributeMap['alt']}');
    }
  }

  //

  // --------------------------------------------------------------------------------

  // Find the image with the same alt as the title
  // TODO add error condition here
  // Element? productImage = images.firstWhereOrNull((image) {
  //   Map<Object, String> attributeMap = image.attributes;
  //
  //   return attributeMap.containsKey('alt') &&
  //       attributeMap['alt'] != null &&
  //       attributeMap['alt']!.length > 10 &&
  //       ((attributeMap['alt']?.replaceAll(RegExp(r"\s+"), " ").contains(data['title']) ?? false) || (attributeMap['title']?.contains(data['alt'].replaceAll(RegExp(r"\s+"), " ")) ?? false))
  //       //attributeMap['alt']!.substring(0, 9) == data["title"].substring(0, 9);
  //   // TODO the above line should be changed to 'contains()'
  // });

  // Now get the source value
  Element productImage = altSimilarImage;
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
  // TODO getting all text but would be better with innerText
  // TODO can't find innerText property.. but it is there....
  // TODO maybe can use xml library ?
  print('text length: ${allText.length}');

  // find the first element that has a '€' or '£' or '$' at the start
  final regex = RegExp(r'([\$|£|€]\d{1,6}\.\d{1,2})');
  final match = regex.firstMatch(allText);
  final matchedText = match?.group(0);
  if (matchedText != null) {
    data['price'] = matchedText;
    print('Price found: $matchedText');
  }

  return data;
}
