// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CategoryAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryAPIModelAdapter extends TypeAdapter<CategoryAPIModel> {
  @override
  final int typeId = 80;

  @override
  CategoryAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryAPIModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CategoryAPIModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.responseBody);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
