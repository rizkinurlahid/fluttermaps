import 'package:flutter/material.dart';
import 'package:flutter_maps/views/widgets/buildCachedImage.dart';

class PhotoProfile extends StatefulWidget {
  final Widget childClipRRect;
  final VoidCallback pilihGalery;
  final IconData icon;
  final String imgUrl;
  final bool isEditable;
  PhotoProfile(
      {this.childClipRRect,
      this.pilihGalery,
      @required this.icon,
      this.imgUrl,
      this.isEditable});
  @override
  _PhotoProfileState createState() => _PhotoProfileState();
}

class _PhotoProfileState extends State<PhotoProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      width: 125,
      child: Stack(
        children: <Widget>[
          (widget.childClipRRect != null && widget.isEditable)
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(125),
                  child: widget.childClipRRect,
                )
              : Container(
                  height: 125,
                  width: 125,
                  child: BuildCachedImage(
                    imgUrl: widget.imgUrl,
                  ),
                ),
          (widget.isEditable)
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: widget.pilihGalery,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: Icon(widget.icon, color: Colors.white),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
