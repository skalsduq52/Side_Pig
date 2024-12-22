package com.yeop.goldenPig.service;

import com.yeop.goldenPig.dto.MoneyDataDTO;
import com.yeop.goldenPig.repository.MoneyRepository;
import com.yeop.goldenPig.vo.MoneyData;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;

@Service
public class MoneyService {

    @Autowired
    private MoneyRepository moneyRepository;

    public MoneyData insertMoneyData(MoneyData moneyData) {
        try {
            // 데이터 저장
            return moneyRepository.save(moneyData);
        } catch (Exception e) {
            // 예외 발생 시 null 반환 또는 커스텀 예외 처리
            throw new RuntimeException("Error saving data: " + e.getMessage(), e);
        }
    }

    public List<MoneyDataDTO> getDataByAndroidID(String androidID, int year, int month){

        LocalDateTime startDate = LocalDateTime.of(year, month, 1, 0, 0);
        LocalDateTime endDate = startDate.withDayOfMonth(startDate.toLocalDate().lengthOfMonth()).withHour(23).withMinute(59).withSecond(59);

        List<MoneyData> list = moneyRepository.findByAndroidIDAndDateBetween(androidID, startDate, endDate);

        Map<LocalDateTime, List<MoneyData>> groupedData = list.stream()
                .collect(Collectors.groupingBy(
                        money -> money.getDate().toLocalDate().atStartOfDay(), // 날짜별 그룹화
                        TreeMap::new,
                        Collectors.toList()
                ));

        groupedData.forEach((date, moneyListForDate) -> {
            moneyListForDate.sort((m1, m2) -> m2.getDate().compareTo(m1.getDate())); // 시간 기준 내림차순 정렬
        });

        return groupedData.entrySet().stream()
                .map(entry -> new MoneyDataDTO(entry.getKey(), entry.getValue())) // DTO로 변환
                .sorted((dto1, dto2) -> dto2.getDate().compareTo(dto1.getDate())) // DTO의 날짜 기준 내림차순 정렬
                .collect(Collectors.toList());
    }
}
