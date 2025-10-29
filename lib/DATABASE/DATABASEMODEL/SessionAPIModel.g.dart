// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SessionAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionAPIModelAdapter extends TypeAdapter<SessionAPIModel> {
  @override
  final int typeId = 82;

  @override
  SessionAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionAPIModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SessionAPIModel obj) {
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
      other is SessionAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
