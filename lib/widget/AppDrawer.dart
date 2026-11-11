import 'package:flutter/material.dart';

class Appdrawer extends StatelessWidget {
  final VoidCallback Home;
  final VoidCallback video;
  final VoidCallback Not;
  final VoidCallback info;
  final VoidCallback explore;

  const Appdrawer({
    super.key,
    required this.Home,
    required this.video,
    required this.info,
    required this.Not,
    required this.explore,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close),
            ),

            Divider(),

            ListTile(title: Text("Home"), onTap: Home),
            ListTile(title: Text("Video"), onTap: video),
            ListTile(title: Text("Information"), onTap: info),
            ListTile(title: Text("Missed"), onTap: Not),
            ListTile(title: Text("Explore"), onTap: explore),
          ],
        ),
      ),
    );
  }
}
