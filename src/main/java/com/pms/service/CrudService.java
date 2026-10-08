package com.pms.service;

/**
 * Generic CRUD service interface for domain objects.
 *
 * @param <T> the type of the domain object
 */
public interface CrudService<T> {
    boolean create(T entity);
    T read(int id);
    boolean update(T entity);
    boolean delete(int id);
}
