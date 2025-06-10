package com.logistics.user.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;

@FeignClient(name = "auth-service", path = "/auth")
public interface AuthServiceClient {
    
    @GetMapping("/validate")
    ResponseEntity<String> validateToken(@RequestHeader("Authorization") String token);
}