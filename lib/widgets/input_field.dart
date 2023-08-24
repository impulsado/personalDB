import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class MyInputField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final int minLines;
  final Widget? child;
  final double? height;
  final TextInputType inputType;
  final TextInputAction? inputAction;
  final bool isLink;
  final TextOverflow? overflow;

  const MyInputField({
    Key? key,
    required this.title,
    required this.hint,
    required this.controller,
    this.minLines = 1,
    this.child,
    this.height,
    this.inputType = TextInputType.text,
    this.inputAction,
    this.isLink = false,
    this.overflow,
  }) : super(key: key);

  void _launchURL(BuildContext context, String url) async {
    if (!url.startsWith("https://") && !url.startsWith("http://")) {
      url = "https://$url";
    }

    final Uri userUrl = Uri.parse(url);

    if (await canLaunchUrl(userUrl)) {
      await launchUrl(userUrl, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch $userUrl")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNumber = inputType == TextInputType.number;

    return Container(
      margin: const EdgeInsets.only(top:16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: subHeadingStyle(color: Colors.black)),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height ?? 50.0,
            ),
            child: Container(
              margin: const EdgeInsets.only(top:8.0),
              padding: const EdgeInsets.only(left:14),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 1.0), borderRadius: BorderRadius.circular(12)),
              child: TextFormField(
                autofocus: false,
                cursorColor: Colors.grey,
                controller: controller,
                style: TextStyle(color: Colors.black, overflow: isNumber ? TextOverflow.ellipsis : overflow),
                keyboardType: inputType,
                minLines: minLines,
                maxLines: isNumber ? 1 : (overflow == TextOverflow.ellipsis ? 1 : null),
                textInputAction: inputAction,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey, overflow: isNumber ? TextOverflow.ellipsis : overflow),
                  focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0)),
                  suffixIcon: isLink ? IconButton(
                    icon: const Icon(Icons.link, color: Colors.black),
                    onPressed: () => _launchURL(context, controller.text),
                  ) : null,
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
