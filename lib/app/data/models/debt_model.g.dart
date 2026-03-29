// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtModelAdapter extends TypeAdapter<DebtModel> {
  @override
  final int typeId = 9;

  @override
  DebtModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DebtModel(
      id: fields[0] as String,
      name: fields[1] as String,
      principalAmount: fields[2] as double,
      interestRate: fields[3] as double,
      emiAmount: fields[4] as double,
      tenureMonths: fields[5] as int,
      startDate: fields[6] as DateTime,
      totalPaid: fields[7] as double,
      debtType: fields[8] as String,
      icon: fields[9] as String,
      color: fields[10] as int,
      notes: fields[11] as String?,
      isActive: fields[12] as bool,
      linkedAccountId: fields[13] as String?,
      emiDay: fields[14] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DebtModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.principalAmount)
      ..writeByte(3)
      ..write(obj.interestRate)
      ..writeByte(4)
      ..write(obj.emiAmount)
      ..writeByte(5)
      ..write(obj.tenureMonths)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.totalPaid)
      ..writeByte(8)
      ..write(obj.debtType)
      ..writeByte(9)
      ..write(obj.icon)
      ..writeByte(10)
      ..write(obj.color)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.isActive)
      ..writeByte(13)
      ..write(obj.linkedAccountId)
      ..writeByte(14)
      ..write(obj.emiDay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
