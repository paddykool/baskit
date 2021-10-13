import 'package:http/http.dart' as http;
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart'; // Contains DOM related classes for extracting data from elements

// make a network call to get the response body

class NetworkCalls {
  String url;
  String title = 'No title yet';
  String urlOfImage = 'No URL of image yet';
  String price = 'No price yet';

  NetworkCalls({required this.url});

  Future<void> getResponseBody() async {
    // make the call
    print('inside getResponseBody()...');

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var document = parse(response.body);

      // find the title...
      List<Element> titles = document.getElementsByTagName('title');
      print('Number of titles found: ${titles.length}');
      title = titles[0].text;
      for (var title in titles) {
        print(title.text);
      }

      // find all image tags
      var images = document.getElementsByTagName('img');
      print('Number of images found: ${images.length}');

      // find the image with the same alt as the title
      Element? productImage = images.firstWhere((image) {
        Map<Object, String> attributeMap = image.attributes;

        return (attributeMap.containsKey('alt') &&
            attributeMap['alt'] != null &&
            attributeMap['alt']!.length > 10 &&
            attributeMap['alt']!.substring(0, 9) == title.substring(0, 9));
      });

      // Now get the source value
      if (productImage != null) {
        print('now checking the source attribute of the productImage...');

        if (productImage.attributes.containsKey('src')) {
          urlOfImage = productImage.attributes['src']!;
          print('URL of source is: $urlOfImage');
        } else {
          print('No src found in image????');
        }
      } else {
        print('productImage element wasn\'t found.......');
      }

      // Find the price - find first element that has '£' in its inner html ??
      var elementList = document.querySelectorAll('*');
      print('elementList length: ${elementList.length}');

      // find the first element that has a '£' at the start
      var priceElement = elementList.firstWhere((element) => element.text.contains(RegExp(r'^£')));
      price = priceElement.text;
      print('Price found: $price');
    } else {
      print('Network error you big dope...');
    }
  }
}
