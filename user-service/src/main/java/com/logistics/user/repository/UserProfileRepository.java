package com.logistics.user.repository;

import com.logistics.user.entity.UserProfile;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserProfileRepository extends JpaRepository<UserProfile, Long> {
    
    Optional<UserProfile> findByAuthUserId(Long authUserId);
    
    Optional<UserProfile> findByUsername(String username);
    
    Optional<UserProfile> findByEmail(String email);
    
    boolean existsByUsername(String username);
    
    boolean existsByEmail(String email);
    
    boolean existsByAuthUserId(Long authUserId);
    
    @Query("SELECT u FROM UserProfile u WHERE " +
           "LOWER(u.firstName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(u.lastName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(u.username) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(u.email) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<UserProfile> findBySearchTerm(@Param("search") String search, Pageable pageable);
    
    @Query("SELECT u FROM UserProfile u WHERE u.status = :status")
    Page<UserProfile> findByStatus(@Param("status") UserProfile.UserStatus status, Pageable pageable);
    
    @Query("SELECT u FROM UserProfile u WHERE u.company = :company")
    Page<UserProfile> findByCompany(@Param("company") String company, Pageable pageable);
}