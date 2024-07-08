import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class PublishPage extends StatefulWidget {
  const PublishPage({super.key});

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  var messageCont = TextEditingController();

  final client = MqttServerClient.withPort('broker.hivemq.com', 'flutter_client_${DateTime.now().millisecondsSinceEpoch}', 1883);
  final String topic = 'demomqtt';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    mqttForUser();
  }

  mqttForUser() async {
    client.logging(on: true);

    try {
      await client.connect();
    } catch (e) {
      debugPrint('Exception: $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('Connected');
      client.onConnected = onconnected;
    } else {
      debugPrint('Connection failed - disconnecting');
      client.disconnect();
    }
  }

  void onconnected() {
    debugPrint('Connected');
  }

  void _sendMessage(String text) {
    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      debugPrint('Not connected');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode({'msg': text}));
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    messageCont.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Publish Message')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: messageCont,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter message',
              ),
              onSubmitted: _sendMessage,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _sendMessage(messageCont.text),
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
