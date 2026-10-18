package com.trixx.smartpos;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class SmartPosApplication {
    public static void main(String[] args) {
        SpringApplication.run(SmartPosApplication.class, args);
    }
}
