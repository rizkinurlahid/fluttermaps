import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BuildCachedImage extends StatelessWidget {
  const BuildCachedImage({
    Key key,
    @required this.imgUrl,
  }) : super(key: key);

  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CachedNetworkImage(
        imageUrl: imgUrl,
        height: 125,
        width: 125,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(125),
          ),
        ),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) =>
            Icon(Icons.error_outline, color: Colors.blue),
      ),
    );
  }
}
