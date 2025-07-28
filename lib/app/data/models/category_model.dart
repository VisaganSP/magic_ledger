import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  int color;

  @HiveField(4)
  double? budget;

  @HiveField(5)
  String? description;

  @HiveField(6)
  bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.budget,
    this.description,
    this.isDefault = false,
  });

  Color get colorValue => Color(color);
}
