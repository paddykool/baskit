import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'navigation/routes.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  static Page page({LocalKey? key}) => MaterialPage(
        key: key,
        child: ErrorScreen(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          color: Colors.red,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: Text(
                'Something happened. Please press button below to go back to home screen',
                style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(Routes.home.path);
        },
        child: Center(
          child: Text('Items List'),
        ),
      ),
    );
  }
}
