import 'package:flutter/cupertino.dart';

Widget loadBrandImage(int? brandId) {
  String imagePath = 'assets/database/$brandId.jpg';
  return ClipRRect(
    borderRadius: BorderRadius.circular(8.0),
    child: Image.asset(
      imagePath,
      width: 48,
      height: 48,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/database/default.jpg',
          width: 48,
          height:48,
          fit: BoxFit.cover,
        );
      },
    ),
  );
}