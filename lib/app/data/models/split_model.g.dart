// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitModelAdapter extends TypeAdapter<SplitModel> {
  @override
  final int typeId = 10;

  @override
  SplitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitModel(
      id: fields[0] as String,
      title: fields[1] as String,
      totalAmount: fields[2] as double,
      expenseId: fields[3] as String?,
      paidBy: fields[4] as String,
      participants: (fields[5] as List).cast<String>(),
      shares: (fields[6] as List).cast<double>(),
      settled: (fields[7] as List).cast<bool>(),
      splitType: fields[8] as String,
      createdAt: fields[9] as DateTime,
      notes: fields[10] as String?,
      categoryId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SplitModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.totalAmount)
      ..writeByte(3)
      ..write(obj.expenseId)
      ..writeByte(4)
      ..write(obj.paidBy)
      ..writeByte(5)
      ..write(obj.participants)
      ..writeByte(6)
      ..write(obj.shares)
      ..writeByte(7)
      ..write(obj.settled)
      ..writeByte(8)
      ..write(obj.splitType)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.categoryId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
