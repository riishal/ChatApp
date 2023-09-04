class ChatRoomModel {
  String? chatroomId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  ChatRoomModel({this.chatroomId, this.participants, this.lastMessage});
  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomId = map["chatroomId"];
    participants = map["participants"];
    lastMessage = map["lastmessage"];
  }
  Map<String, dynamic> toMap() {
    return {
      "chatroomId": chatroomId,
      "participants": participants,
      "lastmessage": lastMessage
    };
  }
}
