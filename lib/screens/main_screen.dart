

import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'paper_trades.dart';
import 'learning.dart';
import 'settings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int selectedIndex = 0;

  final pages = [
    Dashboard(),
    PaperTradesPage(),
    LearningPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("AI Trading Platform"),
      ),

      drawer: Drawer(
        child: ListView(
          children: [

            const DrawerHeader(
              child: Text(
                "Market AI",
                style: TextStyle(fontSize: 24),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text("Paper Trades"),
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text("Learning"),
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                setState(() {
                  selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      body: pages[selectedIndex],
    );
  }
}