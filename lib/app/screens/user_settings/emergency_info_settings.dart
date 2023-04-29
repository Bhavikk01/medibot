import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medibot/app/widgets/background_screen_decoration.dart';

import '../../widgets/box_field.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_input_button.dart';
import '../../widgets/forward_button.dart';
import '../../widgets/text_field.dart';

class EmergencyInfoSettings extends StatelessWidget {
  const EmergencyInfoSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenDecoration(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  text: "Edit User Profile",
                  fontFamily: 'Sansation',
                  size: 23.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ]),
          CustomBox(
              boxHeight: 367.h,
              boxWidth: 265.w,
              margin: EdgeInsets.symmetric(vertical: 45.h, horizontal: 40.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              topRight: Radius.circular(17.r),
              bottomLeft: Radius.circular(17.r),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      margin: EdgeInsets.only(bottom: 15.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 3.w),
                            child: CustomTextField(
                                size: 13.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                                text: "What’s your emergency contact’s name?"),
                          ),
                          CustomInputField(
                              boxHeight: 36.h,
                              boxWidth: 240.w,
                              hintText: "",
                              fontTheme: 'Sansation')
                        ],
                      )),
                  Container(
                    margin: EdgeInsets.only(bottom: 15.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 3.w),
                          child: CustomTextField(
                              size: 13.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                              text: "Emergency contact’s Address"),
                        ),
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomInputField(
                                boxHeight: 36.h,
                                boxWidth: 172.w,
                                hintText: "",
                                fontTheme: 'Sansation'),
                            InputButton(
                                height: 27.5.h,
                                width: 57.w,
                                text: "Fetch current location",
                                fontWeight: FontWeight.w500,
                                textsize: 9.sp,
                                onPressed: (() {}))
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 15.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 3.w),
                          child: CustomTextField(
                              size: 13.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                              text: "Emergency contact’s Contact Number"),
                        ),
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomInputField(
                                boxHeight: 36.h,
                                boxWidth: 172.w,
                                hintText: "",
                                fontTheme: 'Sansation'),
                            InputButton(
                                height: 27.5.h,
                                width: 57.w,
                                text: "Select Contact",
                                fontWeight: FontWeight.w500,
                                textsize: 9.sp,
                                onPressed: (() {}))
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(bottom: 15.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 3.w),
                            child: CustomTextField(
                                size: 13.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                                text: "Emergency contact’s relation with you?"),
                          ),
                          CustomInputField(
                              boxHeight: 36.h,
                              boxWidth: 240.w,
                              hintText: "",
                              fontTheme: 'Sansation')
                        ],
                      )),
                  ForwardButton(
                    width: 255.w,
                    text: 'Continue',
                    padding: EdgeInsets.symmetric(vertical: 9.w),
                    iconSize: 18.h,
                    onPressed: () {
                      log('HelloWorld');
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
