import 'package:flutter/material.dart' show Widget;
import 'package:winball/configs/configs.dart';
import 'package:winball/enums/enums.dart';

class DialogModel {
  final DialogType dialogType;
  final DialogStatus dialogStatus;
  final String title;
  final String description;
  final List<Widget>? buttons;
  const DialogModel({
    required this.dialogType,
    required this.dialogStatus,
    required this.title,
    required this.description,
    required this.buttons,
  });
  DialogModel copyWith({
    DialogType? dialogType,
    DialogStatus? dialogStatus,
    String? title,
    String? description,
    List<Widget>? buttons,
  }) {
    return DialogModel(
      dialogType: dialogType ?? this.dialogType,
      dialogStatus: dialogStatus ?? this.dialogStatus,
      title: title ?? this.title,
      description: description ?? this.description,
      buttons: buttons,
    );
  }

  const DialogModel.loading({
    this.buttons = const [],
    this.description = AppTexts.pleaseWait,
    this.dialogStatus = DialogStatus.open,
    this.dialogType = DialogType.loading,
    this.title = AppTexts.isLoading,
  });
  const DialogModel.error({
    this.buttons = const [],
    this.description = AppTexts.anErrorOccurred,
    this.dialogStatus = DialogStatus.open,
    this.dialogType = DialogType.error,
    this.title = AppTexts.error,
  });
  const DialogModel.closed({
    this.buttons = const [],
    this.description = AppTexts.anErrorOccurred,
    this.dialogStatus = DialogStatus.closed,
    this.dialogType = DialogType.error,
    this.title = AppTexts.error,
  });
  @override
  bool operator ==(covariant DialogModel other) =>
      dialogType == other.dialogType &&
      dialogStatus == other.dialogStatus &&
      title == other.title &&
      description == other.description &&
      buttons == other.buttons;
  @override
  int get hashCode =>
      dialogType.hashCode ^
      dialogStatus.hashCode ^
      title.hashCode ^
      description.hashCode ^
      buttons.hashCode;
}
