import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:medibot/app/models/pills_models/pills_model.dart';

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

  Future<bool> uploadPillsReminderData(PillsModel pillsModel) async {
    var docId = fireStore.collection('pillsReminder').doc().id;
    try {
      await fireStore
          .collection('pillsReminder')
          .doc(docId)
          .set(pillsModel.copyWith(uid: docId).toJson());
      return true;
    } catch (err) {
      log(err.toString());
      return false;
    }
  }


Future<QuerySnapshot<Map<String, dynamic>>?> getCabinetDetail() async { 
    if(UserStore.to.profile.cabinetDetail.isNotEmpty){
      return await fireStore
      .collection('cabinet')
      .doc(UserStore.to.profile.cabinetDetail)
      .collection('cabinetPills')
      .get();
    }else{
      return null;
    }
  }
   Future<bool> uploadCabinetPills(PillsModel pillsModel) async {
    var docId = fireStore.collection('pillsReminder').doc().id;
    try {
      await fireStore
          .collection('cabinet')
          .doc(UserStore.to.profile.cabinetDetail)
          .collection('cabinetPills')
          .doc(docId)
          .set(pillsModel.copyWith(uid: docId).toJson());
      return true;
    } catch (err) {
      log(err.toString());
      return false;
    }
  }

}