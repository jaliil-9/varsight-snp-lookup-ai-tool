import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:varsight/core/constants/sizes.dart';

class StaticContentPage extends StatelessWidget {
  final String title;
  final String markdownFilePath;

  const StaticContentPage({
    super.key,
    required this.title,
    required this.markdownFilePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder(
        future: rootBundle.loadString(markdownFilePath),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Markdown(
              data: snapshot.data!,
              padding: const EdgeInsets.all(Sizes.defaultSpace),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
