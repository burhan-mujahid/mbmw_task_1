import 'dart:io';

import 'package:flutter/material.dart';

class ImagePickerContainer extends StatefulWidget {
  final void Function() getGalleryImage;
  final File? image;
  final String validateText;

  const ImagePickerContainer({
    Key? key,
    required this.getGalleryImage,
    required this.image,
    required this.validateText,
  }) : super(key: key);

  @override
  State<ImagePickerContainer> createState() => _ImagePickerContainerState();
}

class _ImagePickerContainerState extends State<ImagePickerContainer> {
  String? errorText;

  @override
  void initState() {
    super.initState();
    errorText = null;
  }

  void validate() {
    if (widget.image == null) {
      setState(() {
        errorText = widget.validateText;
      });
    } else {
      setState(() {
        errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          widget.getGalleryImage();
          validate();
        },
        child: Container(
          height: MediaQuery.of(context).size.width * 0.4,
          width: MediaQuery.of(context).size.width * 0.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.image != null)
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.file(widget.image!),
                ),
              if (widget.image == null) Center(child: Icon(Icons.image)),
              if (errorText != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Center(
                      child: Text(
                        errorText!,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
