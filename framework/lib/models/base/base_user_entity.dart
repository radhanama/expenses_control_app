import 'package:flutter/foundation.dart';
import "entity_mapper.dart";

abstract class BaseUserEntity with ChangeNotifier, EntityMapper {
  @override
  final int? id;
  final int usuarioId;

  BaseUserEntity({this.id, required this.usuarioId});
}
