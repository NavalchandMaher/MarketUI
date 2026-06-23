
import 'package:flutter/material.dart';



// ================= SETTINGS PAGE =================
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [

        ListTile(
          title: const Text(
            "Auto Learning",
          ),
          trailing: Switch(
            value: true,
            onChanged: (_) {},
          ),
        ),

        ListTile(
          title: const Text(
            "Paper Trading",
          ),
          trailing: Switch(
            value: true,
            onChanged: (_) {},
          ),
        ),

        ListTile(
          title: const Text(
            "Telegram Alerts",
          ),
          trailing: Switch(
            value: false,
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }
}