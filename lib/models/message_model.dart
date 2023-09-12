MessageModel messageModelFromMap(Map<String, dynamic> data) =>
    MessageModel.fromMap(data);
Map<String, dynamic> messageModelToMap(MessageModel data) => data.toMap();

class MessageModel {
  String? messageId;
  String? sender;
  String? text;
  bool? lastseen;
  DateTime? createdone;
  MessageModel(
      {this.sender,
      this.text,
      this.lastseen = false,
      this.createdone,
      this.messageId});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    lastseen = map["lastseen"];
    createdone = map["createdone"].toDate();
  }
  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "text": text,
      "lastseen": lastseen,
      "createdone": createdone,
      "messageid": messageId
    };
  }
}
