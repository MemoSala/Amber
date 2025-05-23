import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'open_image.dart';

class ImageApp extends StatefulWidget {
  const ImageApp(this.refImage, {super.key});
  final String refImage;
  @override
  State<ImageApp> createState() => _ImageAppState();
}

class _ImageAppState extends State<ImageApp> {
  Color colorApp = Colors.amber;
  List<String> folders = [], images = [], imagesUrl = [];
  bool keyOpen = false;
  List<String> listRefImage = [];

  @override
  void initState() {
    getImages();
    super.initState();
  }

  getImages() async {
    setState(() => keyOpen = false);
    String refImage = widget.refImage;
    for (var element in listRefImage) {
      refImage += "/$element";
    }
    ListResult ref = await FirebaseStorage.instance.ref(refImage).list();
    setState(() {
      folders = [];
      images = [];
      imagesUrl = [];
    });
    setState(() => keyOpen = true);
    setState(() {
      for (Reference item in ref.prefixes) {
        folders.add(item.name);
      }
    });
    for (Reference item in ref.items) {
      String url = await item.getDownloadURL();
      setState(() {
        images.add(item.name);
        imagesUrl.add(url);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Image"),
        actions: [
          IconButton(
            onPressed: () => getImages(),
            icon: const Icon(Icons.save_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: keyOpen
          ? RefreshIndicator(
              onRefresh: () => getImages(),
              child: GridView(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                children: [
                  if (listRefImage.isNotEmpty)
                    widgetFile(
                      onTap: () {
                        setState(() =>
                            listRefImage.removeAt(listRefImage.length - 1));
                        getImages();
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 120,
                      ),
                      text: "Back",
                    ),
                  for (String folder in folders)
                    widgetFile(
                      onTap: () {
                        setState(() => listRefImage.add(folder));
                        getImages();
                      },
                      child: const Icon(Icons.folder, size: 140),
                      text: folder,
                    ),
                  for (int i = 0; i < images.length; i++)
                    widgetFile(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OpenImage(
                          imageUrl: imagesUrl[i],
                          imageName: images[i],
                        ),
                      )),
                      child: Image.network(imagesUrl[i]),
                      text: images[i],
                    ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  InkWell widgetFile({
    required void Function() onTap,
    required Widget child,
    required String text,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(children: [
        Expanded(child: child),
        SizedBox(
          height: 40,
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ]),
    );
  }

  Radio<Color> newRadio(color) {
    return Radio(
      value: color,
      groupValue: colorApp,
      fillColor: MaterialStatePropertyAll(color),
      onChanged: (value) => setState(() => colorApp = value!),
    );
  }
}
