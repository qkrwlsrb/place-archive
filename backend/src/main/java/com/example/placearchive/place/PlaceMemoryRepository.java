package com.example.placearchive.place;

import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PlaceMemoryRepository extends JpaRepository<PlaceMemory, Long> {

    Page<PlaceMemory> findByUserId(Long userId, Pageable pageable);

    @Query("select p from PlaceMemory p left join fetch p.images where p.id = :id")
    Optional<PlaceMemory> findByIdWithImages(@Param("id") Long id);

    @Query("select distinct p from PlaceMemory p left join fetch p.images where p.id in :ids")
    List<PlaceMemory> findAllByIdInWithImages(@Param("ids") List<Long> ids);

    @Query("""
            select p from PlaceMemory p
            where p.isPublic = true
              and (:keyword is null
                   or lower(p.title) like lower(concat('%', :keyword, '%'))
                   or lower(p.memo) like lower(concat('%', :keyword, '%'))
                   or lower(p.address) like lower(concat('%', :keyword, '%')))
            """)
    Page<PlaceMemory> searchPublic(@Param("keyword") String keyword, Pageable pageable);
}
