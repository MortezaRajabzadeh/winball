abstract class BaseModel {
  const BaseModel();
  factory BaseModel.fromJson({required String jsonData}) {
    throw UnimplementedError();
  }
  factory BaseModel.fromMap({required Map<String, dynamic> mapData}) {
    throw UnimplementedError();
  }
  Map<String, dynamic> get toMap => {};
  String get toJson => '';
  BaseModel copyWith() {
    throw UnimplementedError();
  }

  @override
  String toString() => toJson;
}
