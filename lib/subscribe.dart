import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  List<String> myList = [];

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
      client.onSubscribed = onSubscribed;
      debugPrint('Connected');
      client.subscribe(topic, MqttQos.atLeastOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        print('EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
        setState(() {
          myList.add(jsonDecode(pt)['msg']);
        });
      });
      client.onConnected = onconnected;
    } else {
      debugPrint('Connection failed - disconnecting');
      client.disconnect();
    }
  }

  void onconnected() {
    debugPrint('Connected');
  }

  void onSubscribed(String topic) {
    debugPrint('Subscribed to $topic');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subscribed Messages')),
      body: ListView.builder(
        itemCount: myList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(myList[index]),
          );
        },
      ),
    );
  }
}
