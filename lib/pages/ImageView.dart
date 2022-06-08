import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageView extends StatefulWidget {
  ImageView({Key? key}) : super(key: key);
 static const routeName = "/imageviewpage";
  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  bool isInit = true;
  late String url;

  @override
  void didChangeDependencies() {
    if (isInit) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      // ignore: unnecessary_null_comparison
      if (args == null) {
        return;
      }
      url = args['url'];
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
appBar: AppBar(
  backgroundColor: Colors.transparent,
),
      body: InteractiveViewer(
        panEnabled: false,
        maxScale: 10,
        child: Center(
          child: Hero(
            tag: url,
            child: CachedNetworkImage(
              
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Image.asset(
                  "assets/images/Capture5.PNG",
                  fit: BoxFit.cover,
                ),
              )),
        ),
      ),
    );
  }
}
