import 'dart:convert';

import 'package:base_repository/base_repository.dart';

class SliderModel implements BaseModel {
  final int id;
  final String imagePath;
  final String? buttonTitle;
  final String? buttonLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SliderModel({
    required this.id,
    required this.imagePath,
    required this.buttonTitle,
    required this.buttonLink,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  SliderModel copyWith({
    String? imagePath,
    String? buttonTitle,
    String? buttonLink,
  }) {
    return SliderModel(
      id: id,
      imagePath: imagePath ?? this.imagePath,
      buttonTitle: buttonTitle,
      buttonLink: buttonLink,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  factory SliderModel.fromMap({required Map<String, dynamic> mapData}) {
    return SliderModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      imagePath: mapData['image_path'],
      buttonTitle: mapData['button_title'] == null
          ? null
          : mapData['button_title']['String'],
      buttonLink: mapData['button_link'] == null
          ? null
          : mapData['button_link']['String'],
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }
  @override
  factory SliderModel.fromJson({required String jsonData}) =>
      SliderModel.fromMap(mapData: jsonDecode(jsonData));

  @override
  String get toJson => jsonEncode(toMap);

  @override
  Map<String, dynamic> get toMap => {
        'id': '$id',
        'image_path': imagePath,
        'button_title': {'String': buttonTitle},
        'button_link': {'String': buttonLink},
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  static List<SliderModel> getListOfSliderByJson({required String jsonData}) {
    final List<SliderModel> slider = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        slider.add(SliderModel.fromMap(mapData: mapData));
      }
    }
    return slider;
  }
}
