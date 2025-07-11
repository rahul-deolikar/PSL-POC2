package com.poc3.javahelloapi.controller;

import com.poc3.javahelloapi.dto.HelloRequest;
import com.poc3.javahelloapi.dto.HelloResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Map;

@RestController
@CrossOrigin(origins = "*")
public class HelloController {

    @GetMapping("/")
    public ResponseEntity<HelloResponse> home() {
        HelloResponse response = new HelloResponse(
                "Hello World from Java Spring Boot API!",
                "1.0.0",
                "Java Spring Boot 3.2",
                Instant.now().toString(),
                null
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/api/hello")
    public ResponseEntity<HelloResponse> hello(@RequestParam(defaultValue = "World") String name) {
        HelloResponse response = new HelloResponse(
                String.format("Hello, %s!", name),
                "1.0.0",
                "Java Spring Boot",
                Instant.now().toString(),
                null
        );
        return ResponseEntity.ok(response);
    }

    @PostMapping("/api/hello")
    public ResponseEntity<HelloResponse> helloPost(@RequestBody HelloRequest request) {
        String name = request.getName() != null ? request.getName() : "World";
        HelloResponse response = new HelloResponse(
                String.format("Hello, %s! (POST request)", name),
                "1.0.0",
                "Java Spring Boot",
                Instant.now().toString(),
                Map.of("received", request)
        );
        return ResponseEntity.ok(response);
    }
}