// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingsGoalModelAdapter extends TypeAdapter<SavingsGoalModel> {
  @override
  final int typeId = 8;

  @override
  SavingsGoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingsGoalModel(
      id: fields[0] as String,
      name: fields[1] as String,
      targetAmount: fields[2] as double,
      savedAmount: fields[3] as double,
      icon: fields[4] as String,
      color: fields[5] as int,
      createdAt: fields[6] as DateTime,
      targetDate: fields[7] as DateTime?,
      notes: fields[8] as String?,
      isCompleted: fields[9] as bool,
      linkedAccountId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SavingsGoalModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.targetAmount)
      ..writeByte(3)
      ..write(obj.savedAmount)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.targetDate)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.linkedAccountId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsGoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
