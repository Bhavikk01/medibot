import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:medibot/app/models/pills_models/pills_model.dart';

import '../models/history_model/history_model.dart';
import '../models/user_model/user_model.dart';
import 'user.dart';

class FirebaseFireStore extends GetxController {
  static FirebaseFireStore get to => Get.find();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  String verificationId = '';

  handleSignInByPhone(String phoneNumber) async {
    await auth.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? forceResendingToken) {
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
    );
  }

  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    final credential = PhoneAuthProvider.credential(
      smsCode: otp,
      verificationId: verificationId,
    );
    final value = await auth.signInWithCredential(credential);
    if (value.user != null) {
      UserModel? user = await getUser(value.user!.uid);
      if (user == null) {
        user = UserModel(
          username: '',
          uid: value.user!.uid,
          userProfile: '',
          phoneNumber: phoneNumber,
          email: '',
          address: '',
          cabinetDetail: '',
          age: 0,
          careTaker: const CareTakerModel(
            careTakerAddress: '',
            careTakerName: '',
            caretakerPhone: '',
            uid: '',
          ),
          emergencyPerson: const EmergencyPersonModel(
            emergencyAddress: '',
            emergencyName: '',
            emergencyPhone: '',
            emergencyRelation: '',
          ),
          physicalDeviceLink: '',
          userStatus: AuthStatus.newUser,
        );
        await addUserData(user);
      }
      await UserStore.to.saveProfile(user.uid);
      return true;
    } else {
      return false;
    }
  }

  Future<void> addUserData(UserModel user) async {
    await fireStore.collection('Users').doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUser(String userId) async {
    var userData = await fireStore.collection('Users').doc(userId).get();
    return userData.exists
        ? UserModel.fromJson(userData.data() as Map<String, dynamic>)
        : null;
  }

  Future<void> updateUserData(UserModel userModel) async {
    await fireStore
        .collection('Users')
        .doc(userModel.uid)
        .set(userModel.toJson());
    await UserStore.to.saveProfile(userModel.uid);
  }

  Future<UserModel?> getUserByPhone(String phoneNumber) async {
    log('Phone number: $phoneNumber');
    final doc = await fireStore
        .collection("Users")
        .where('phoneNumber', isEqualTo: phoneNumber.trim())
        .get();
    log('This is the doc : ${doc.docs}');
    if (doc.docs.isNotEmpty) {
      UserModel userModel = UserModel.fromJson(doc.docs.first.data());
      await UserStore.to.saveProfile(userModel.uid);
      log('THis is the user: $userModel');
      return userModel;
    } else {
      return null;
    }
  }

  Future<bool> checkUserAccount(String phoneNumber) async {
    UserModel? userModel = await getUserByPhone(phoneNumber);
    if (userModel != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> uploadPillsReminderData(PillsModel pillsModel) async {
    var docId = fireStore.collection('pillsReminder').doc().id;
    try {
      await fireStore
          .collection('pillsReminder')
          .doc(docId)
          .set(pillsModel.copyWith(uid: docId).toJson());
      return docId;
    } catch (err) {
      log(err.toString());
      return '';
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCabinetDetail() {
      return fireStore
          .collection('cabinets')
          .doc(UserStore.to.profile.cabinetDetail)
          .collection('pillsReminder')
          .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllCabinetPills() {
    return fireStore
        .collection('cabinets')
        .doc(UserStore.to.profile.cabinetDetail)
        .collection('pillsReminder')
        .snapshots();
  }

  Future<bool> uploadCabinetPills(PillsModel pillsModel) async {
    var docId = fireStore.collection('cabinets').doc().id;
    try {
      await fireStore
          .collection('cabinets')
          .doc(UserStore.to.profile.cabinetDetail)
          .collection('pillsReminder')
          .doc(docId)
          .set(pillsModel.copyWith(uid: docId).toJson());
      return true;
    } catch (err) {
      log(err.toString());
      return false;
    }
  }

  Future<void> updatePillsData(PillsModel pillsModel) async {
    log('hello in updating');
    await fireStore
        .collection('pillsReminder')
        .doc(pillsModel.uid)
        .update(pillsModel.toJson());
    log('hello in updating');
  }

  Future<void> updateCabinetData(PillsModel pillsModel) async {
    log('hello in updating');
    await fireStore
        .collection('cabinets')
        .doc(UserStore.to.profile.cabinetDetail)
        .collection('pillsReminder')
        .doc(pillsModel.uid)
        .update(pillsModel.toJson());
    log('hello in updating');
  }

  Future<void> uploadHistoryData(HistoryModel historyModel, String docId) async {
    await fireStore
        .collection('History')
        .doc(UserStore.to.uid)
        .collection('history_data')
        .doc(docId)
        .set(historyModel.toJson());
  }

  Future<QuerySnapshot<Map<String, dynamic>>?> getHistoryData() async {
    var data = await fireStore
        .collection('History')
        .doc(UserStore.to.uid)
        .collection('history_data')
        .get();
    if(data.docs.isNotEmpty){
      return data;
    } else {
      return null;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getTodayHistory() async {

    var history = await fireStore
        .collection('History')
        .doc(UserStore.to.uid)
        .collection('history_data')
        .doc('${DateTime.now().year}:${DateTime.now().month < 10 ? '0${DateTime.now().month}' : DateTime.now().month}:${DateTime.now().day < 10 ? '0${DateTime.now().day}' : DateTime.now().day}')
        .get();
    log('Getting data : ${history.data()} at : ${DateTime.now().year}:${DateTime.now().month}:${DateTime.now().day}');
    if(history.exists){
      return history;
    }else{
      log('Its null');
      return null;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getHistoryDataByDay(String docId) async {
    var data = await fireStore
        .collection('History')
        .doc(UserStore.to.uid)
        .collection('history_data')
        .doc(docId)
        .get();
    if(data.exists){
      return data;
    } else{
      return null;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPillReminder(String actionId) async {
    return await fireStore
        .collection('pillsReminder')
        .where('uid', isEqualTo: actionId)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllPillsReminder() {
    return fireStore
        .collection('pillsReminder')
        .where('userId', isEqualTo: UserStore.to.uid)
        .snapshots();
  }

}