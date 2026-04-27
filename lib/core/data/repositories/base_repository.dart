abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(int id);
  Future<int> insert(T model);
  Future<void> update(T model);
  Future<void> delete(int id);
}
