/// lib/modelsbase/entity_mapper.dart
mixin EntityMapper {
  /// The DB table name that stores this entity.
  String get tableName;

  int? get id;
  Map<String, dynamic> toMap();
}
