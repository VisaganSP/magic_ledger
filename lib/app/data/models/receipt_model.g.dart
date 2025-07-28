// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceiptModelAdapter extends TypeAdapter<ReceiptModel> {
  @override
  final int typeId = 4;

  @override
  ReceiptModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReceiptModel(
      id: fields[0] as String,
      expenseId: fields[1] as String,
      imagePath: fields[2] as String,
      uploadDate: fields[3] as DateTime,
      extractedText: fields[4] as String?,
      extractedData: (fields[5] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.expenseId)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.uploadDate)
      ..writeByte(4)
      ..write(obj.extractedText)
      ..writeByte(5)
      ..write(obj.extractedData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
