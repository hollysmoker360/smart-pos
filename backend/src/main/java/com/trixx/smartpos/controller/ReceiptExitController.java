package com.trixx.smartpos.controller;

import com.trixx.smartpos.model.ExitEvent;
import com.trixx.smartpos.model.ExitToken;
import com.trixx.smartpos.model.Receipt;
import com.trixx.smartpos.service.ReceiptExitService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/v1")
public class ReceiptExitController {

    private final ReceiptExitService receiptExitService;

    public ReceiptExitController(ReceiptExitService receiptExitService) {
        this.receiptExitService = receiptExitService;
    }

    @GetMapping("/orders/{id}/receipt")
    public ResponseEntity<Receipt> getReceipt(@PathVariable UUID id) {
        Receipt receipt = receiptExitService.generateReceipt(id);
        return ResponseEntity.ok(receipt);
    }

    @GetMapping("/orders/{id}/exit-token")
    public ResponseEntity<ExitToken> getExitToken(@PathVariable UUID id) {
        ExitToken token = receiptExitService.getExitTokenForOrder(id);
        return ResponseEntity.ok(token);
    }

    @PostMapping("/exit/verify")
    public ResponseEntity<Map<String, Object>> verifyExitToken(@RequestBody Map<String, String> body) {
        String tokenHash = body.get("tokenHash");
        if (tokenHash == null) {
            throw new IllegalArgumentException("tokenHash is required");
        }
        Map<String, Object> result = receiptExitService.verifyExitToken(tokenHash);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/exit/complete")
    public ResponseEntity<ExitEvent> completeExit(@RequestBody Map<String, Object> body) {
        String tokenHash = (String) body.get("tokenHash");
        Boolean inspectionPerformed = body.get("inspectionPerformed") != null ? (Boolean) body.get("inspectionPerformed") : false;
        String notes = (String) body.get("notes");

        ExitEvent event = receiptExitService.completeExit(tokenHash, null, inspectionPerformed, notes);
        return ResponseEntity.ok(event);
    }
}
