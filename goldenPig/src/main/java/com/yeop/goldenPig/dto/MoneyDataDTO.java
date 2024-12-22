package com.yeop.goldenPig.dto;

import com.yeop.goldenPig.vo.MoneyData;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class MoneyDataDTO {

    private LocalDateTime date;
    private List<MoneyData> data;

    public MoneyDataDTO(LocalDateTime date, List<MoneyData> data) {
        this.date = date;
        this.data = data;
    }
}
