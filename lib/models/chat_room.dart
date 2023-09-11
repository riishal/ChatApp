class ChatRoomModel {
  String? chatroomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  List<dynamic>? users;
  DateTime? createdone;
  bool seen = false;
  ChatRoomModel(
      {this.chatroomId,
      this.participants,
      this.lastMessage,
      this.users,
      this.createdone,
      this.seen = false});
  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomId = map["chatroomId"];
    participants = map["participants"];
    lastMessage = map["lastmessage"];
    users = map["users"];
    createdone = map["createdone"].toDate();
    seen = map["seen"];
  }
  Map<String, dynamic> toMap() {
    return {
      "chatroomId": chatroomId,
      "participants": participants,
      "lastmessage": lastMessage,
      "users": users,
      "createdone": createdone,
      "seen": seen
    };
  }
}
