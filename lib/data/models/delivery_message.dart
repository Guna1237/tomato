class DeliveryMessage {
  final String id;
  final String deliveryId;
  final String senderId;
  final String body;
  final DateTime createdAt;

  const DeliveryMessage({
    required this.id,
    required this.deliveryId,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  factory DeliveryMessage.fromJson(Map<String, dynamic> json) =>
      DeliveryMessage(
        id: json['id'] as String,
        deliveryId: json['delivery_id'] as String,
        senderId: json['sender_id'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
