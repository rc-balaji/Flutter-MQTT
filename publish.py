import paho.mqtt.client as mqtt
import json
import time

# Define the MQTT client
client = mqtt.Client()

# Connect to the MQTT broker
client.connect("broker.hivemq.com", 1883, 60)

# Function to publish a message
def publish_message(client, topic, message):
    # Create a JSON payload
    payload = json.dumps({"msg": message})
    # Publish the message to the specified topic
    client.publish(topic, payload)
    print(f"Published message: {message}")

# Example usage: Publish a message to the 'demomqtt' topic
while 1:

  topic = "demomqtt"
  message = input()

  # Publish the message
  publish_message(client, topic, message)

# Allow some time for the message to be sent
time.sleep(1)

# Disconnect from the broker
client.disconnect()
