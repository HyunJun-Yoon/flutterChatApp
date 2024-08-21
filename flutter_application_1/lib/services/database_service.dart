import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/chat.dart';
import 'package:flutter_application_1/models/message.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils.dart';
import 'package:get_it/get_it.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late AuthService _authService;

  CollectionReference? _usersCollection;
  CollectionReference? _chatsCollection;

  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    _setupCollectionReferences();
  }

  void _setupCollectionReferences() {
    _usersCollection =
        _firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) => UserProfile.fromJson(
                snapshots.data()!,
              ),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
    _chatsCollection = _firebaseFirestore
        .collection('chats')
        .withConverter<Chat>(
            fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
            toFirestore: (chat, _) => chat.toJson());
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Future<void> updateUserProfile({required UserProfile userProfile}) async {
    await _usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Future<void> updateUserChat({
    required String uid,
    required String chatId,
  }) async {
    await _usersCollection?.doc(uid).update({
      'chatId': FieldValue.arrayUnion([chatId]), // Assuming chatIDs is a list
    });
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _usersCollection
        ?.where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Stream<List<UserProfile>?> getChatUserProfiles() async* {
    // Initialize the users collection with a converter
    CollectionReference<UserProfile> _usersCollection = FirebaseFirestore
        .instance
        .collection('users')
        .withConverter<UserProfile>(
          fromFirestore: (snapshot, _) =>
              UserProfile.fromJson(snapshot.data()!),
          toFirestore: (userProfile, _) => userProfile.toJson(),
        );

    // Fetch the current user's chatId list
    DocumentSnapshot<UserProfile> currentUserDoc =
        await _usersCollection.doc(_authService.user!.uid).get();

    // Extract the UserProfile object
    UserProfile? currentUserProfile = currentUserDoc.data();

    // Handle the case where the user profile or chatId list is null
    if (currentUserProfile == null || currentUserProfile.chatId == null) {
      yield null;
      return;
    }

    List<String> currentUserChatIds = currentUserProfile.chatId!;

    // Stream of other users' profiles
    Stream<QuerySnapshot<UserProfile>> userProfilesStream = _usersCollection
        .where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots();

    await for (var snapshot in userProfilesStream) {
      // Filter the documents to find users with matching chatId
      var matchingProfiles = snapshot.docs
          .where((doc) {
            UserProfile otherUserProfile = doc.data();
            List<String>? otherUserChatIds = otherUserProfile.chatId;

            // Check if the other user's chatId list is not null and has any common chatId
            return otherUserChatIds != null &&
                currentUserChatIds
                    .any((chatId) => otherUserChatIds.contains(chatId));
          })
          .map((doc) => doc.data())
          .toList();

      // If there are no matching profiles, yield null
      if (matchingProfiles.isEmpty) {
        yield null;
      } else {
        // Yield the list of matching UserProfile objects
        yield matchingProfiles;
      }
    }
  }

  Future<bool> checkChatExits(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatsCollection?.doc(chatID).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2, String userName) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    Message message = Message(
      senderID: uid1,
      content: userName + " 님이 채팅을 시작하였습니다.",
      messageType: MessageType.Text,
      sentAt: Timestamp.fromDate(DateTime.now()),
    );
    final docRef = _chatsCollection!.doc(chatID);
    final chat = Chat(
      id: chatID,
      participants: [uid1, uid2],
      messages: [],
    );
    await docRef.set(chat);

    await sendChatMessage(uid1, uid2, message);
    await updateUserChat(uid: uid1, chatId: chatID);
    await updateUserChat(uid: uid2, chatId: chatID);
  }

  Future<void> deleteChat(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);

    // Delete the chat document
    await _chatsCollection?.doc(chatID).delete();

    // Remove chat ID from both users' profiles
    await _usersCollection?.doc(uid1).update({
      'chatId': FieldValue.arrayRemove([chatID]),
    });

    await _usersCollection?.doc(uid2).update({
      'chatId': FieldValue.arrayRemove([chatID]),
    });
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatID);
    await docRef.update(
      {
        "messages": FieldValue.arrayUnion(
          [
            message.toJson(),
          ],
        ),
      },
    );
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatsCollection?.doc(chatID).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }

  Future<void> storeRating({
    required String loggedInUserId,
    required String otherUserId,
    required int rating,
    required double currentTransactionAmount,
  }) async {
    try {
      // Reference to the ratings collection of the other user
      CollectionReference ratingsCollection =
          _usersCollection!.doc(otherUserId).collection('ratings');

      // Add a new rating document with the current timestamp, rating, and ratedBy fields
      await ratingsCollection.doc().set({
        'rating': rating,
        'totalTransaction': currentTransactionAmount,
        'ratedAt': Timestamp.now(),
        'ratedBy':
            loggedInUserId, // Store the ID of the user who gave the rating
      });

      // Reference to the other user's document
      DocumentReference userDocRef = _usersCollection!.doc(otherUserId);

      await _firebaseFirestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userDocRef);

        if (userDoc.exists) {
          int currentGrade = userDoc.get('grade') ?? 0;
          double currentTotalTransaction = userDoc.get('totalTransaction') ?? 0;
          int currentNumberOfTransaction =
              userDoc.get('numberOfTransaction') ?? 0;

          // Update the grade by adding the new rating
          int newGrade = currentGrade + rating;

          // Increment the number of transactions
          int newNumberOfTransaction = currentNumberOfTransaction + 1;

          double newTotalTransaction =
              currentTotalTransaction + currentTransactionAmount;

          // Update the user's document with the new values
          transaction.update(userDocRef, {
            'grade': newGrade,
            'numberOfTransaction': newNumberOfTransaction,
            'totalTransaction': newTotalTransaction,
          });
        }
      });
    } catch (e) {
      print("Error storing rating: $e");
      throw e;
    }
  }
}
