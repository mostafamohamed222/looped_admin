import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../res/color_manager.dart';

class TextFormWithBackground extends StatefulWidget {
  TextFormWithBackground({
    super.key,
    required this.hintText,
    required this.type,
    required this.errorEmpty,
    required this.controller,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.showPassword = false,
    this.showError = true,
    this.maxLength = 0,
    this.maxLines = 1,
    this.showCounter = true,
    this.wrong = false,
    this.errorWrong,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.onTap,
    this.isAddress = false,
    this.showInvalidError = false,
    this.invalidError = "",
    this.isEmail = false,
    this.isSearch = false,
    this.isFilter = false,
    this.isBigPadding = false,
    this.enabled = true,
    this.textAlign = TextAlign.start,
  });
  final bool isBigPadding;
  final bool showInvalidError;
  final String invalidError;
  final bool isEmail;
  final FocusNode focus = FocusNode();
  final bool showCounter;
  final bool showError;
  final String hintText;
  final TextInputType type;
  final bool enabled;
  final String errorEmpty;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool showPassword;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final int maxLength;
  final int maxLines;
  final bool? wrong;
  final String? errorWrong;
  final TextInputAction textInputAction;
  final bool isAddress;
  final bool isSearch;
  final bool isFilter;
  final TextAlign textAlign;
  @override
  State<TextFormWithBackground> createState() => _TextFormWithBackgroundState();
}

class _TextFormWithBackgroundState extends State<TextFormWithBackground> {
  bool showEmptyText = false;
  bool showInvalidError = false;
  @override
  void initState() {
    super.initState();
    widget.focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    widget.focus.removeListener(_onFocusChange);
    widget.focus.dispose();
  }

  void _onFocusChange() {
    if (widget.focus.hasFocus == false) {
      if (widget.controller.text.isEmpty) {
        setState(() {
          showEmptyText = true;
        });
      } else {
        setState(() {
          showEmptyText = false;
        });
      }
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: ColorManager.whiteColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 5,
                blurStyle: BlurStyle.outer,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextFormField(
            enabled: widget.enabled,
            readOnly: widget.type == TextInputType.none,
            style: const TextStyle(
              color: ColorManager.mainColor,
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
            onTap: () {
              // Remove focus to hide keyboard before executing external onTap logic (e.g., date pickers)
              if (widget.onTap != null) {
                widget.focus.unfocus();
                widget.onTap!();
              }
            },
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            onTapOutside: (event) {
              widget.focus.unfocus();
            },
            cursorColor: ColorManager.blackColor,
            maxLength: widget.maxLength == 0 ? null : widget.maxLength,
            maxLines: widget.maxLines,
            onChanged: (value) {
              if (widget.onChanged != null) {
                widget.onChanged!(value);
              }
              if (showEmptyText) {
                if (widget.controller.text.isNotEmpty) {
                  setState(() {
                    showEmptyText = false;
                  });
                }
              } else {
                if (widget.controller.text.isEmpty) {
                  setState(() {
                    showEmptyText = true;
                  });
                }
              }
            },
            validator: (value) {
              if (value!.isEmpty) {
                setState(() {
                  showEmptyText = true;
                });
                return null;
              }
              return null;
            },
            obscureText: widget.showPassword,
            controller: widget.controller,
            focusNode: widget.focus,
            keyboardType: widget.type,
            textAlign: widget.textAlign,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              counterText: widget.showCounter ? null : "",
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: widget.isSearch || widget.isFilter
                  ? Colors.transparent
                  : ColorManager.whiteColor,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              border: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.isBigPadding ? 40 : 12,
                vertical: 20,
              ),
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                  color: ColorManager.noDataColor), // Changed to main color
              alignLabelWithHint: widget.maxLines == 1 ? null : true,
            ),
          ),
        ),
      ],
    );
  }
}
