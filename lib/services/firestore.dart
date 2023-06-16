import 'package:chatbot/model/chat_message.dart';
import 'package:chatbot/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  Future createUser({required String name, required String email}) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(
          Auth().currentUser!.uid,
        );
    final json = {
      'name': name,
      'email': email,
    };
    await docUser.set(json);
  }

  Future<void> saveListToFirestore(List<ChatMessage> dataList) async {
    // Create a new document reference
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.uid)
        .collection('chats')
        .doc();

    // Convert the list to a format Firestore understands (List of Maps)
    List<Map<String, dynamic>> messagesMap = dataList
        .map((message) => {
              'transcript': message.transcript,
              'type': message.type.toString(), // Assuming type is an enum
            })
        .toList();

    // Save the list to Firestore
    await documentReference.set({'messages': messagesMap});
  }

  Stream<List<String>> getChatsStream() {
    // Get the collection reference
    CollectionReference collectionReference = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.uid)
        .collection('chats');

    return collectionReference.snapshots().map(
      (querySnapshot) {
        List<String> dataList = [];
        for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
          dataList.add(documentSnapshot.id);
        }
        return dataList;
      },
    );
  }

  Future<List<ChatMessage>> getListFromFirestore(
      {required String chatId}) async {
    // Get the document reference
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.uid)
        .collection('chats')
        .doc(chatId);

    // Get the document snapshot
    DocumentSnapshot documentSnapshot = await documentReference.get();

    // Check if the document exists
    if (documentSnapshot.exists) {
      // Get the data from the document
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      // Get the list of messages from the data
      List<dynamic> messages = data['messages'];

      // Convert the list of maps to a List<ChatMessage>
      List<ChatMessage> dataList = messages
          .map((message) => ChatMessage(
                transcript: message['transcript'],
                type: ChatType.values
                    .firstWhere((e) => e.toString() == message['type']),
              ))
          .toList();

      return dataList;
    } else {
      // Document doesn't exist, return an empty list or handle the absence of data accordingly
      return [];
    }
  }
}
