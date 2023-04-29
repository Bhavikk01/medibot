import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medibot/app/widgets/text_field.dart';

class CustomCheckBox extends StatelessWidget {
  final String text;
  final bool checked;
  const CustomCheckBox({required this.text, required this.checked, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextField(
            size: 12.sp,
            fontWeight: FontWeight.w100,
            text: text,
            color: Colors.black,
          ),
          Transform.scale(
            scaleX: 2.0,
            scaleY: 2.0,
            child: Checkbox(
              activeColor: const Color(0xffCEE2FF),
              checkColor: Colors.black,
              shape:
                  const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              value: checked,
              onChanged: (value) {},
            ),
          )
        ],
      ),
    );
  }
}
