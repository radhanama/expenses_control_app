import 'base/base_user_entity.dart';

/// Abstração para o padrão Composite em categorias.
/// Uma categoria pode conter outras categorias e expõe operações
/// para gerenciamento da hierarquia.
abstract class CategoriaComponent<T extends CategoriaComponent<T>>
    extends BaseUserEntity {
  CategoriaComponent({super.id, required super.usuarioId});

  String get titulo;
  String get descricao;
  int? get parentId;

  List<T> get subcategorias;

  T adicionarSubcategoria(T c);
  T removerSubcategoria(T c);

  String getDescricaoCompleta({String separator = ' > '});
}
