import 'package:flutter/material.dart';

class TableDatePoint extends StatelessWidget {
  final String title;
  final String data;
  const TableDatePoint({Key key, this.title, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              
            ),
          ),
          Text(
            data,
            style: TextStyle(
              fontSize: 20
            ),
          )
        ],
      ),
    );
  }
}