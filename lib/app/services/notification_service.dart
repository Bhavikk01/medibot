import 'dart:developer';
import 'dart:math' as math;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:medibot/app/models/pills_models/pills_model.dart';

import 'package:timezone/timezone.dart' as tz;

class NotificationService extends GetxController {
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  late InitializationSettings initSettings;
  String messagingToken = '';

  static NotificationService get to => Get.find();

  @override
  Future<void> onInit() async {
    await initPermission();
    await getToken();
    await initializeNotifications();
    log('Scheduling pill');
    await AndroidAlarmManager.oneShotAt(
      DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      math.Random().nextInt(math.pow(2, 31) as int),
      () {
        localNotifications.zonedSchedule(
          math.Random().nextInt(math.pow(2, 31) as int),
          'title',
          'body',
          tz.TZDateTime.from(
            DateTime.now(),
            tz.local
          ),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'pillsModel.uid',
              'pillsModel.pillName',
              importance: Importance.max,
              priority: Priority.max,
              icon: '@mipmap/ic_launcher',
              category: AndroidNotificationCategory.reminder,
              actions: [
                AndroidNotificationAction(
                  'uid',
                  'Taken',
                  cancelNotification: false,
                  titleColor: Colors.green,
                ),
                AndroidNotificationAction(
                  '',
                  'Missed',
                  cancelNotification: false,
                  titleColor: Colors.red,
                ),
              ],
              autoCancel: false,
              enableVibration: true,
              visibility: NotificationVisibility.public,
            ),
          ),
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      },
      exact: true,
      wakeup: true,
    );
    super.onInit();
  }

  initPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      sound: true,
      provisional: true,
      carPlay: true,
      criticalAlert: false,
      badge: true,
      announcement: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User Granted Permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User Granted Permission as on provisional');
    } else {
      log("User haven't granted permission");
    }
  }

  getToken() async {
    await messaging.getToken().then((token) {
      messagingToken = token ?? '';
      log(messagingToken);
    });
  }

  initializeNotifications() async {
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    await AndroidAlarmManager.initialize();
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );
    initSettings = const InitializationSettings(android: androidInitializationSettings);
    await localNotifications.initialize(initializationSettings);
  }


  Future<void> handleBackgroundMessage(RemoteMessage message) async{
    log('Title: ${message.notification!.title}');
    log('Body: ${message.notification!.body}');
  }

  scheduleNotification(int id, PillsModel pillsModel, List<DateTime> duration) async {
    if (pillsModel.isRange) {
      for (var interval in pillsModel.pillsInterval) {
        if (interval.substring(0, 2) == '00' && interval.substring(5, 7) == '00') {
        } else {
          log('Setting up notification now');
          await localNotifications.zonedSchedule(
            id,
            'MediBot',
            'Its time to take ${pillsModel.pillName} pill',
            tz.TZDateTime.from(
              DateTime(
                duration.first.year,
                duration.first.month,
                duration.first.day,
                int.parse(interval.substring(0, 2)),
                int.parse(interval.substring(5, 7))+2,
              ),
              tz.local,
            ),
            NotificationDetails(
              android: AndroidNotificationDetails(
                pillsModel.uid,
                pillsModel.pillName,
                importance: Importance.max,
                priority: Priority.max,
                icon: '@mipmap/ic_launcher',
                category: AndroidNotificationCategory.reminder,
                actions: [
                  AndroidNotificationAction(
                    pillsModel.uid,
                    'Taken',
                    cancelNotification: false,
                    titleColor: Colors.green,
                  ),
                  const AndroidNotificationAction(
                    '',
                    'Missed',
                    cancelNotification: false,
                    titleColor: Colors.red,
                  ),
                ],
                autoCancel: false,
                enableVibration: true,
                visibility: NotificationVisibility.public,
              ),
            ),
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        }
      }
    } else {
      for (var individualDuration in duration) {
        for (var interval in pillsModel.pillsInterval) {
          if (interval.substring(0, 2) == '00' &&
              interval.substring(5, 7) == '00') {
          } else {
            log('Setting up notification now');
            await localNotifications.zonedSchedule(
              id,
              'MediBot',
              'Its time to take ${pillsModel.pillName} pill',
              tz.TZDateTime(
                tz.local,
                individualDuration.year,
                individualDuration.month,
                individualDuration.day,
                int.parse(interval.substring(0, 2)),
                int.parse(interval.substring(5, 7)),
              ),
              NotificationDetails(
                android: AndroidNotificationDetails(
                  pillsModel.uid,
                  pillsModel.pillName,
                  importance: Importance.max,
                  priority: Priority.max,
                  icon: '@mipmap/ic_launcher',
                  category: AndroidNotificationCategory.reminder,
                  actions: [
                    AndroidNotificationAction(
                      pillsModel.uid,
                      'Taken',
                      cancelNotification: false,
                      titleColor: Colors.green,
                    ),
                    const AndroidNotificationAction(
                      '',
                      'Missed',
                      cancelNotification: false,
                      titleColor: Colors.red,
                    ),
                  ],
                  autoCancel: false,
                  enableVibration: true,
                  visibility: NotificationVisibility.public,
                ),
              ),
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            );
            log('Setting up notification complete');
          }
        }
      }
    }

    // localNotifications.initialize(
    //   initSettings,
    //   onDidReceiveNotificationResponse: (NotificationResponse details) async {
    //     if (details.actionId != '') {
    //       String docId = "${DateTime.now().year}:${DateTime.now().month < 10 ? '0${DateTime.now().month}' : DateTime.now().month}:${DateTime.now().day < 10 ? '0${DateTime.now().day}' : DateTime.now().day}";
    //       var dayHistory = await FirebaseFireStore.to.getHistoryDataByDay(docId);
    //       HistoryModel historyModel = HistoryModel.fromJson(dayHistory.data() as Map<String, dynamic>);
    //       late HistoryData historyData;
    //       int? index;
    //       for (var pill in historyModel.historyData) {
    //         if (pill.pillId == details.actionId) {
    //           historyData = pill;
    //           index = historyModel.historyData.indexOf(pill);
    //           break;
    //         }
    //       }
    //       if (index == null) {
    //         var pillReminder = await FirebaseFireStore.to.getPillReminder(details.actionId!);
    //         historyModel.historyData.add(
    //           HistoryData(
    //             pillId: details.actionId!,
    //             timeToTake: pillReminder.docs.first.data()['pillsInterval'],
    //             timeTaken: [DateTime.now()],
    //           ),
    //         );
    //       } else {
    //         historyData.timeTaken.add(DateTime.now());
    //         historyModel.historyData[index] = historyData;
    //       }
    //       await FirebaseFireStore.to.uploadHistoryData(
    //         historyModel.copyWith(historyData: historyModel.historyData),
    //         docId,
    //       );
    //     }
    //   },
    //   onDidReceiveBackgroundNotificationResponse: (NotificationResponse details) async {
    //     if (details.actionId != '') {
    //       String docId = "${DateTime.now().year}:${DateTime.now().month < 10 ? '0${DateTime.now().month}' : DateTime.now().month}:${DateTime.now().day < 10 ? '0${DateTime.now().day}' : DateTime.now().day}";
    //       var dayHistory = await FirebaseFireStore.to.getHistoryDataByDay(docId);
    //       HistoryModel historyModel = HistoryModel.fromJson(dayHistory.data() as Map<String, dynamic>);
    //       late HistoryData historyData;
    //       int? index;
    //       for (var pill in historyModel.historyData) {
    //         if (pill.pillId == details.actionId) {
    //           historyData = pill;
    //           index = historyModel.historyData.indexOf(pill);
    //           break;
    //         }
    //       }
    //       if (index == null) {
    //         var pillReminder = await FirebaseFireStore.to.getPillReminder(details.actionId!);
    //         historyModel.historyData.add(
    //           HistoryData(
    //             pillId: details.actionId!,
    //             timeToTake: pillReminder.docs.first.data()['pillsInterval'],
    //             timeTaken: [DateTime.now()],
    //           ),
    //         );
    //       } else {
    //         historyData.timeTaken.add(DateTime.now());
    //         historyModel.historyData[index] = historyData;
    //       }
    //       await FirebaseFireStore.to.uploadHistoryData(
    //         historyModel.copyWith(historyData: historyModel.historyData),
    //         docId,
    //       );
    //     }
    //   },
    // );
  }

  scheduleAlert(int id, PillsModel pillsModel, List<DateTime> duration) async {
    if (pillsModel.isRange) {
      for (var interval in pillsModel.pillsInterval) {
        if (interval.substring(0, 2) == '00' &&
            interval.substring(5, 7) == '00') {
        } else {
          log('Setting up notification now');
          await AndroidAlarmManager.oneShotAt(
            DateTime(
              duration.first.year,
              duration.first.month,
              duration.first.day,
              int.parse(interval.substring(0, 2)),
              int.parse(interval.substring(5, 7)),
            ), // Repeat interval
            id,
            () async {
              if (interval.substring(0, 2) == '00' && interval.substring(5, 7) == '00') {
              } else {
                log('Setting up notification now');
                await localNotifications.show(
                  id,
                  'MediBot',
                  'Its time to take ${pillsModel.pillName} pill',
                  NotificationDetails(
                    android: AndroidNotificationDetails(
                      pillsModel.uid,
                      pillsModel.pillName,
                      importance: Importance.max,
                      priority: Priority.max,
                      icon: '@mipmap/ic_launcher',
                      category: AndroidNotificationCategory.reminder,
                      actions: [
                        AndroidNotificationAction(
                          pillsModel.uid,
                          'Taken',
                          cancelNotification: false,
                          titleColor: Colors.green,
                        ),
                        const AndroidNotificationAction(
                          '',
                          'Missed',
                          cancelNotification: false,
                          titleColor: Colors.red,
                        ),
                      ],
                      autoCancel: false,
                      enableVibration: true,
                      visibility: NotificationVisibility.public,
                    ),
                  ),
                );
                log('Setting up notification complete');
              }
            },
            wakeup: true,
            exact: true,
            rescheduleOnReboot: false,
          );
        }
      }
    } else {
      for (var individualDuration in duration) {
        for (var interval in pillsModel.pillsInterval) {
          if (interval.substring(0, 2) == '00' && interval.substring(5, 7) == '00') {
          } else {
            log('Setting up notification now');
            await AndroidAlarmManager.oneShotAt(
              DateTime(
                individualDuration.year,
                individualDuration.month,
                individualDuration.day,
                int.parse(interval.substring(0, 2)),
                int.parse(interval.substring(5, 7)),
              ),
              id,
              () async {
                if (interval.substring(0, 2) == '00' &&
                    interval.substring(5, 7) == '00') {
                } else {
                  log('Setting up notification now');
                  await localNotifications.show(
                    id,
                    'MediBot',
                    'Its time to take ${pillsModel.pillName} pill',
                    NotificationDetails(
                      android: AndroidNotificationDetails(
                        pillsModel.uid,
                        pillsModel.pillName,
                        importance: Importance.max,
                        priority: Priority.max,
                        icon: '@mipmap/ic_launcher',
                        category: AndroidNotificationCategory.reminder,
                        actions: [
                          AndroidNotificationAction(
                            pillsModel.uid,
                            'Taken',
                            cancelNotification: false,
                            titleColor: Colors.green,
                          ),
                          const AndroidNotificationAction(
                            '',
                            'Missed',
                            cancelNotification: false,
                            titleColor: Colors.red,
                          ),
                        ],
                        autoCancel: false,
                        enableVibration: true,
                        visibility: NotificationVisibility.public,
                      ),
                    ),
                  );
                  log('Setting up notification complete');
                }
              },
              wakeup: true,
              exact: true,
              rescheduleOnReboot: false,
            );
            log('Setting up notification complete');
          }
        }
      }
    }
  }
}
