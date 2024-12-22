package com.yeop.goldenPig.vo;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Table(name = "MONEYDATA")
public class MoneyData {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long OID;

    @Column(name = "ANDROIDID", nullable = false )
    private String androidID;

    @Column(name = "DATE", nullable = false)
    private LocalDateTime date;

    @Column(name = "AMOUNT", nullable = false)
    private int amount;

    @Column(name = "CATEGORY", nullable = false)
    private String category;

    @Column(name = "PAYMENTMETHOD", nullable = false)
    private String paymentMethod;

    @Column(name = "CONTENT", nullable = false)
    private String content;

    @Column(name = "TYPE", nullable = false)
    private String type;
}
