package com.logistics.user.repository;

import com.logistics.user.entity.UserActivity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface UserActivityRepository extends JpaRepository<UserActivity, Long> {
    
    Page<UserActivity> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);
    
    List<UserActivity> findByUserIdAndActivityType(Long userId, UserActivity.ActivityType activityType);
    
    @Query("SELECT ua FROM UserActivity ua WHERE ua.userId = :userId AND ua.createdAt BETWEEN :startDate AND :endDate")
    List<UserActivity> findByUserIdAndDateRange(@Param("userId") Long userId, 
                                               @Param("startDate") LocalDateTime startDate, 
                                               @Param("endDate") LocalDateTime endDate);
    
    @Query("SELECT COUNT(ua) FROM UserActivity ua WHERE ua.userId = :userId AND ua.activityType = :activityType")
    Long countByUserIdAndActivityType(@Param("userId") Long userId, 
                                     @Param("activityType") UserActivity.ActivityType activityType);
}