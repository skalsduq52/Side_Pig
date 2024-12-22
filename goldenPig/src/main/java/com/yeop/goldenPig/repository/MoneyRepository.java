package com.yeop.goldenPig.repository;

import com.yeop.goldenPig.vo.MoneyData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface MoneyRepository extends JpaRepository<MoneyData, Long> {
    List<MoneyData> findByAndroidIDAndDateBetween(String androidID, LocalDateTime startDate, LocalDateTime endDate);
}
