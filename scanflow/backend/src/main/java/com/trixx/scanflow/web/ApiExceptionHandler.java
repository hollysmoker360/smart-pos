package com.trixx.scanflow.web;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import com.trixx.scanflow.service.BasketEventPublisher;

@RestControllerAdvice
public class ApiExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> handleInvalidRequest(MethodArgumentNotValidException exception) {
        return ResponseEntity.badRequest().body(new ApiError("Invalid request"));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiError> handleBusinessRuleViolation(IllegalArgumentException exception) {
        return ResponseEntity.badRequest().body(new ApiError(exception.getMessage()));
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiError> handleDataConflict(DataIntegrityViolationException exception) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(new ApiError("The request conflicts with existing data"));
    }

    @ExceptionHandler(BasketEventPublisher.SubscriberLimitExceededException.class)
    public ResponseEntity<ApiError> handleSubscriberLimit(BasketEventPublisher.SubscriberLimitExceededException exception) {
        return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS).body(new ApiError(exception.getMessage()));
    }

    public record ApiError(String message) {}
}