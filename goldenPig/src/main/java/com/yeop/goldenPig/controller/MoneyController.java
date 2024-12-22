package com.yeop.goldenPig.controller;

import com.yeop.goldenPig.dto.MoneyDataDTO;
import com.yeop.goldenPig.service.MoneyService;
import com.yeop.goldenPig.vo.MoneyData;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/money")
public class MoneyController {

    @Autowired
    private MoneyService moneyService;

    @GetMapping("/day")
    public List<MoneyDataDTO> getDataByAndroidID(@RequestParam("androidID") String androidID,
                                                 @RequestParam("year") int year,
                                                 @RequestParam("month") int month) {

        List<MoneyDataDTO> list  = moneyService.getDataByAndroidID(androidID, year, month);
        return list;
    }

    @PostMapping()
    public ResponseEntity<String> saveMoneyData(@RequestBody MoneyData data) {
        try {
            MoneyData savedData = moneyService.insertMoneyData(data);

            if (savedData != null) {
                return ResponseEntity.ok("Data saved successfully!");
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("Failed to save data.");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("An error occurred: " + e.getMessage());
        }
    }

}
