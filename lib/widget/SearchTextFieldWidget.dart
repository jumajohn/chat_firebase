import 'package:flutter/material.dart';

class SearchTextFieldWidget extends StatefulWidget {
  SearchTextFieldWidget({Key? key, required this.closeTextbox})
      : super(key: key);

  final Function closeTextbox;

  @override
  State<SearchTextFieldWidget> createState() => _SearchTextFieldWidgetState();
}

class _SearchTextFieldWidgetState extends State<SearchTextFieldWidget> {
  TextEditingController textController = TextEditingController();

  void clearTextField() {
    setState(() {
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: TextField(
        onChanged: (_) {
          setState(() {});
        },
        controller: textController,
        style: const TextStyle(fontSize: 20),
        decoration: InputDecoration(
          hintText: "Search...",
          hintStyle: const TextStyle(color: Colors.grey,fontSize: 20),
         border: InputBorder.none,
          prefixIcon: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.closeTextbox();
            },
          ),
          suffixIcon: !textController.text.isEmpty
              ? IconButton(
                  onPressed: clearTextField,
                  icon: const Icon(Icons.close),
                )
              : null,
        ),
      ),
    );
  }
}
