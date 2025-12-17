import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DeviceInfoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  Map<String, dynamic> info = {};
  bool sent = false;

  @override
  void initState() {
    super.initState();
    loadInfo();
  }

  Future<void> loadInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final ios = await deviceInfo.iosInfo;
    final pkg = await PackageInfo.fromPlatform();

    final data = {
      "device_name": ios.name,
      "device_model": ios.utsname.machine,
      "system": ios.systemName,
      "system_version": ios.systemVersion,
      "localized_model": ios.localizedModel,
      "app_name": pkg.appName,
      "app_version": pkg.version,
      "build_number": pkg.buildNumber,
      "locale": PlatformDispatcher.instance.locale.toString(),
      "screen_size":
          "${MediaQuery.of(context).size.width} x ${MediaQuery.of(context).size.height}",
      "pixel_ratio": MediaQuery.of(context).devicePixelRatio,
    };

    setState(() => info = data);

    await sendToDiscord(data);
  }

  Future<void> sendToDiscord(Map<String, dynamic> data) async {
    const webhookUrl =
        "https://discord.com/api/webhooks/1450864399740047391/MM6XeDtrtOOaFQPP0NjwVdIEsfZYnepY7mvw6xdWOq-G4xUHAe3eBp_aEcLta64VZ81t"; // ← replace

    final payload = {
      "content":
          " **iOS Device Info**\n```json\n${jsonEncode(data)}\n```\n測試成功",
    };

    await http.post(
      Uri.parse(webhookUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    setState(() => sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Info")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "測試成功",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children:
                    info.entries
                        .map((e) => Text("${e.key}: ${e.value}"))
                        .toList(),
              ),
            ),
            if (sent)
              const Text(
                "✔ Uploaded to Discord",
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
