import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medibot/app/models/history_model/history_model.dart';
import 'package:medibot/app/models/pills_models/pills_model.dart';
import 'package:medibot/app/services/firestore.dart';

import '../../../services/user.dart';

class HomepageController extends GetxController {

  RxList<HistoryData> historyList = <HistoryData>[].obs;
  RxList<PillsModel> reminderList = <PillsModel>[].obs;
  var loadingUserData = true.obs;
  var pillIndex = 0.obs;
  var pillsTaken = 0.obs;
  var pillsToTake = 0.obs;


  @override
  Future<void> onInit() async {
    await getUserData();
    log('Pills : ${pillsTaken.value} , ${pillsToTake.value}');
    super.onInit();
  }


  Future<void> getUserData() async {
    loadingUserData.value = true;
    var todayHistory = await FirebaseFireStore.to.getTodayHistory();
    var pillsReminder = FirebaseFireStore.to.getAllPillsReminder();
    var cabinetPillsReminder = FirebaseFireStore.to.getAllCabinetPills();

    pillsReminder.listen((snapshot) {
      for(var pill in snapshot.docChanges){
        switch(pill.type){
          case DocumentChangeType.added:
            PillsModel pillsModel = PillsModel.fromJson(pill.doc.data()!);
            if(pillsModel.isIndividual) {
              List<DateTime> dates = pillsModel.pillsDuration.map((e) => DateTime.parse(e)).toList();
              if(dates.contains(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))){
                reminderList.add(pillsModel);
                if(todayHistory != null){
                  var history = HistoryModel.fromJson(todayHistory.data() as Map<String, dynamic>);
                  for(var historyData in history.historyData){
                    if(historyData.pillId == reminderList.last.uid){
                      historyList.add(historyData);
                      pillsTaken.value += historyList.last.timeTaken.length;
                      pillsToTake.value += reminderList.last.pillsInterval.length;
                      break;
                    }
                  }
                  if(historyList.last.pillId != reminderList.last.uid){
                    historyList.add(HistoryData(pillId: reminderList.last.uid, timeTaken: [], timeToTake: reminderList.last.pillsInterval));
                    pillsTaken.value += historyList.last.timeTaken.length;
                    pillsToTake.value += reminderList.last.pillsInterval.length;
                  }
                }else{
                  pillsTaken.value = 0;
                  pillsToTake.value += reminderList.last.pillsInterval.length;
                }
              }
            }else{
              List<DateTime> dates = pillsModel.pillsDuration.map((e) => DateTime.parse(e)).toList();
              if(dates.first.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)) || dates.last.isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))){
                reminderList.add(pillsModel);
                if(todayHistory != null){
                  var history = HistoryModel.fromJson(todayHistory.data() as Map<String, dynamic>);
                  for(var historyData in history.historyData){
                    if(historyData.pillId == reminderList.last.uid){
                      historyList.add(historyData);
                      pillsTaken.value += historyList.last.timeTaken.length;
                      pillsToTake.value += reminderList.last.pillsInterval.length;
                      break;
                    }
                  }
                  if(historyList.last.pillId != reminderList.last.uid){
                    historyList.add(HistoryData(pillId: reminderList.last.uid, timeTaken: [], timeToTake: reminderList.last.pillsInterval));
                    pillsTaken.value += historyList.last.timeTaken.length;
                    pillsToTake.value += reminderList.last.pillsInterval.length;
                  }
                }else{
                  pillsTaken.value = 0;
                  pillsToTake.value += reminderList.last.pillsInterval.length;
                }
              }
            }
            break;
          case DocumentChangeType.modified:
            // TODO: Handle this case.
            break;
          case DocumentChangeType.removed:
            // TODO: Handle this case.
            break;
        }
      }
    });
    cabinetPillsReminder.listen((snapshot) {
      for(var pill in snapshot.docChanges){
        switch(pill.type) {
          case DocumentChangeType.added:
            PillsModel pillsModel = PillsModel.fromJson(pill.doc.data()!);
            if(pillsModel.isIndividual) {
              List<DateTime> dates = pillsModel.pillsDuration.map((e) => DateTime.parse(e)).toList();
              if(dates.contains(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))){
                reminderList.add(pillsModel);
                if(todayHistory != null){
                  var history = HistoryModel.fromJson(todayHistory.data() as Map<String, dynamic>);
                  for(var historyData in history.historyData){
                    if(historyData.pillId == reminderList.last.uid){
                      historyList.add(historyData);
                      pillsTaken.value += historyList.last.timeTaken.length;
                      pillsToTake.value += reminderList.last.pillsInterval.length;
                      break;
                    }
                  }
                  if(historyList.last.pillId != reminderList.last.uid){
                    historyList.add(HistoryData(pillId: reminderList.last.uid, timeTaken: [], timeToTake: reminderList.last.pillsInterval));
                    pillsTaken.value += historyList.last.timeTaken.length;
                    pillsToTake.value += reminderList.last.pillsInterval.length;
                  }
                }
              }
            }else{
              List<DateTime> dates = pillsModel.pillsDuration.map((e) => DateTime.parse(e)).toList();
              if(dates.first.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)) || dates.last.isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))){
                reminderList.add(pillsModel);
                if(todayHistory != null){
                  var history = HistoryModel.fromJson(todayHistory.data() as Map<String, dynamic>);
                  for(var historyData in history.historyData){
                    if(historyData.pillId == reminderList.last.uid){
                      historyList.add(historyData);
                      pillsTaken.value += historyList.last.timeTaken.length;
                      pillsToTake.value += reminderList.last.pillsInterval.length;
                      break;
                    }
                  }
                  if(historyList.last.pillId != reminderList.last.uid){
                    historyList.add(HistoryData(pillId: reminderList.last.uid, timeTaken: [], timeToTake: reminderList.last.pillsInterval));
                    pillsTaken.value += historyList.last.timeTaken.length;
                    pillsToTake.value += reminderList.last.pillsInterval.length;
                  }
                }else{
                  pillsTaken.value = 0;
                  pillsToTake.value += reminderList.last.pillsInterval.length;
                }
              }
            }
            break;
          case DocumentChangeType.modified:
            // TODO: Handle this case.
            break;
          case DocumentChangeType.removed:
            // TODO: Handle this case.
            break;
        }
      }
      loadingUserData.value = false;
      log('This is the history list: $historyList');
      log('This is the reminder list: $reminderList');
      log('Pills : ${pillsTaken.value} , ${pillsToTake.value}');

    });

  }

  bool findPillStatus() {
    if(historyList.isEmpty){
      return false;
    }
    int diff1 = historyList[pillIndex.value].timeTaken.last.hour - int.parse(historyList[pillIndex.value].timeToTake[historyList[pillIndex.value].timeTaken.length-1].substring(0,2));
    int diff2 = historyList[pillIndex.value].timeTaken.last.minute - int.parse(historyList[pillIndex.value].timeToTake[historyList[pillIndex.value].timeTaken.length-1].substring(5,7));
    var diff3 = diff2/60;
    if(diff1+diff3 <= 2){
      return true;
    }else{
      return false;
    }
  }

  String checkDue() {
    for(var interval in reminderList[pillIndex.value].pillsInterval){
      if(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(interval.substring(0,2)), int.parse(interval.substring(5,7))).isAfter(DateTime.now())){
        log('This is interval $interval');
        if(int.parse(interval.substring(0,2)) == 12){
          return '${interval.substring(0,2)} : ${interval.substring(5,7)} PM';
        }else if(int.parse(interval.substring(0,2)) > 12){
          int diff = int.parse(interval.substring(0,2)) - 12;
          if(diff > 9){
            return '$diff : ${interval.substring(5,7)} PM';
          }else{
            return '0$diff : ${interval.substring(5,7)} PM';
          }
        }else{
          if(int.parse(interval.substring(0,2)) > 9){
            return '${int.parse(interval.substring(0,2))} : ${interval.substring(5,7)} AM';
          }else{
            return '0${int.parse(interval.substring(0,2))} : ${interval.substring(5,7)} AM';
          }
        }
        return interval;
      }
    }
    return '';
  }

  Future<void> takeNowPill() async {
    String docId = "${DateTime.now().year}:${DateTime.now().month < 10 ? '0${DateTime.now().month}' : DateTime.now().month}:${DateTime.now().day < 10 ? '0${DateTime.now().day}' : DateTime.now().day}";
    var dayHistory = await FirebaseFireStore.to.getHistoryDataByDay(docId);
    if(dayHistory != null){
      HistoryModel historyModel = HistoryModel.fromJson(dayHistory.data() as Map<String, dynamic>);
      late HistoryData historyData;
      int? index;
      for (var pill in historyModel.historyData) {
        if (pill.pillId == reminderList[pillIndex.value].uid) {
          historyData = pill;
          index = historyModel.historyData.indexOf(pill);
          break;
        }
      }
      if (index == null) {
        var pillReminder = await FirebaseFireStore.to.getPillReminder(reminderList[pillIndex.value].uid);
        historyModel.historyData.add(
          HistoryData(
            pillId: reminderList[pillIndex.value].uid,
            timeToTake: reminderList[pillIndex.value].pillsInterval,
            timeTaken: [DateTime.now()],
          ),
        );
      } else {
        if(historyData.timeTaken.length < historyData.timeToTake.length) {
          historyData.timeTaken.add(DateTime.now());
          historyModel.historyData[index] = historyData;
        }else{
          Get.snackbar(
            "Reminders",
            "Can't take anymore pills",
            icon: const Icon(
              Icons.check_sharp,
              color: Colors.black,
            ),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xffA9CBFF),
            margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            colorText: Colors.black,
          );
        }
      }
      await FirebaseFireStore.to.uploadHistoryData(
        historyModel.copyWith(historyData: historyModel.historyData),
        docId,
      );
    } else {
      HistoryModel historyModel = HistoryModel(
        userId: UserStore.to.uid,
        historyData: []
      );
      var pillReminder = await FirebaseFireStore.to.getPillReminder(reminderList[pillIndex.value].uid);
      historyModel.historyData.add(
        HistoryData(
          pillId: docId,
          timeToTake: pillReminder.docs.first.data()['pillsInterval'],
          timeTaken: [DateTime.now()],
        ),
      );
      await FirebaseFireStore.to.uploadHistoryData(
        historyModel.copyWith(historyData: historyModel.historyData),
        docId,
      );
    }
  }

}
