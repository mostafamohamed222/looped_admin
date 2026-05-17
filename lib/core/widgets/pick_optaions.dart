import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../res/color_manager.dart';
import 'build_text.dart';

class ChoiceChipWidget extends StatefulWidget {
  const ChoiceChipWidget({super.key, required this.options});
  final List<String> options;
  @override
  _ChoiceChipWidgetState createState() => _ChoiceChipWidgetState();
}

class _ChoiceChipWidgetState extends State<ChoiceChipWidget> {
  // Use a set to keep track of selected indices
  int _selectedIndices = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 15.0,
        children: List<Widget>.generate(
          widget.options.length,
          (int index) {
            return ChoiceChip(
              label: BuildText(
                txt: widget.options[index],
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _selectedIndices == index
                    ? ColorManager.blueColor
                    : ColorManager.grayTextColor,
              ),
              selected: _selectedIndices == index,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedIndices = index;
                  } else {
                    _selectedIndices = -1;
                  }
                });
              },
              selectedColor: Colors.blue.withOpacity(.08),
              backgroundColor: ColorManager.disableTextColor,
              // disabledColor: Colors.transparent,
              // labelStyle: TextStyle(
              //   color: _selectedIndices == index ? Colors.white : Colors.black,
              //   fontWeight: FontWeight.bold,
              // ),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: _selectedIndices == index
                      ? Colors.blue.withOpacity(.08)
                      : ColorManager.disableTextColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
