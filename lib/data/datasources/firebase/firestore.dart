import 'package:chatbot/domain/entities/chat_message_entity.dart';
import 'package:chatbot/data/datasources/firebase/auth.dart';
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

  Future getUser() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(
          Auth().currentUser!.uid,
        );
    final doc = await docUser.get();
    return doc.data();
  }

  Future updateUser({required String name, required String email}) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(
          Auth().currentUser!.uid,
        );
    final json = {
      'name': name,
      'email': email,
    };
    await docUser.update(json);
  }

  Future<String> saveChatMessages(
      String chatID, List<ChatMessage> messages) async {
    DocumentReference documentReference;
    if (chatID == "") {
      // If the chatID is empty, create a new document reference
      documentReference = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().currentUser!.uid)
          .collection('chats')
          .doc();
    } else {
      // If the chatID is not empty, use the existing chatID to update the document reference
      documentReference = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().currentUser!.uid)
          .collection('chats')
          .doc(chatID);
    }

    // Convert the list to a format Firestore understands (List of Maps)
    List<Map<String, dynamic>> messagesMap = messages
        .map((message) => {
              'transcript': message.transcript,
              'type': message.type.toString(), // Assuming type is an enum
            })
        .toList();

    // Save the list to Firestore
    await documentReference.set({'messages': messagesMap});

    return documentReference.id;
  }

  Future<void> deleteChatMessages(String chatID) async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.uid)
        .collection('chats')
        .doc(chatID);

    // Delete the document
    await documentReference.delete();
  }

  Stream<List<String>> getAllChats() {
    // Get the collection reference
    CollectionReference collectionReference = FirebaseFirestore.instance
        .collection('users')
        .doc(Auth().currentUser!.uid)
        .collection('chats');

    return collectionReference.snapshots().map(
      (querySnapshot) {
        List<String> chats = [];
        for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
          chats.add(documentSnapshot.id);
        }
        return chats;
      },
    );
  }

  Future<List<ChatMessage>> getAllChatMessages({required String chatId}) async {
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
      List<ChatMessage> chat = messages
          .map((message) => ChatMessage(
                transcript: message['transcript'],
                type: ChatType.values
                    .firstWhere((e) => e.toString() == message['type']),
              ))
          .toList();

      return chat;
    } else {
      // Document doesn't exist, return an empty list or handle the absence of data accordingly
      return [];
    }
  }
}
