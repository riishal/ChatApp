class MessageModel {
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdone;
  MessageModel({this.sender, this.text, this.seen, this.createdone});

  MessageModel.fromMap(Map<String, dynamic> map) {
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdone = map["createdone"].toDate();
  }
  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdone": createdone
    };
  }
}
