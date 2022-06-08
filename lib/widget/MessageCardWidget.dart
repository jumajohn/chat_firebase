import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../pages/ImageView.dart';

class MessageCardWidget extends StatefulWidget {
  const MessageCardWidget(
      {Key? key,
      required this.text,
      required this.url,
      required this.type,
      required this.isMe,
      required this.createdAt})
      : super(key: key);

  final String text;
  final String url;
  final String type;
    final String createdAt;
  final bool isMe;

  @override
  State<MessageCardWidget> createState() => _MessageCardWidgetState();
}

class _MessageCardWidgetState extends State<MessageCardWidget> {
  Widget imageWidget(BuildContext context,String imageUrl) {
    final screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () => Navigator.of(context)
          .pushNamed(ImageView.routeName, arguments: {"url": imageUrl}),
      child: Hero(
        tag: imageUrl,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: CachedNetworkImage(
            width: (screenWidth * 60) / 100,
            height: ((screenWidth * 60) / 100) / 1.7,
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => Image.asset(
              "assets/images/Capture5.PNG",
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment:
          widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                constraints: BoxConstraints(maxWidth: (screenWidth * 60) / 100),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: widget.isMe
                        ? const Radius.circular(12)
                        : const Radius.circular(0),
                    bottomRight: widget.isMe
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                  ),
                  color: widget.isMe ? Colors.grey[300] : Colors.blue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.url != "0") imageWidget(context,widget.url),
                    Container(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        widget.text,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Text(DateFormat("dd MMMM, yyyy - hh:mm:aa").format(
                    DateTime.fromMillisecondsSinceEpoch(int.parse(widget.createdAt)))),
              )
            ],
          ),
        )
      ],
    );
  }
}
