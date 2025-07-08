package com.teamcity.cicd.controller;

import com.teamcity.cicd.model.HelloResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.constraints.NotBlank;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

@RestController
@RequestMapping("/api")
@Validated
@Tag(name = "Hello World API", description = "Simple Hello World endpoints for TeamCity CI/CD Pipeline")
@CrossOrigin(origins = "*")
public class HelloController {

    @GetMapping("/hello")
    @Operation(summary = "Get Hello World message", description = "Returns a simple Hello World message")
    public ResponseEntity<HelloResponse> hello() {
        HelloResponse response = new HelloResponse(
                "Hello World from Java Spring Boot!",
                "1.0.0",
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME),
                "Java + Spring Boot"
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/hello/{name}")
    @Operation(summary = "Get personalized Hello message", description = "Returns a personalized Hello message")
    public ResponseEntity<HelloResponse> helloName(
            @Parameter(description = "Name to greet", required = true)
            @PathVariable @NotBlank String name) {
        
        HelloResponse response = new HelloResponse(
                String.format("Hello %s from Java Spring Boot!", name),
                "1.0.0",
                LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME),
                "Java + Spring Boot"
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/")
    @Operation(summary = "Get API information", description = "Returns API information and available endpoints")
    public ResponseEntity<Map<String, Object>> root() {
        return ResponseEntity.ok(Map.of(
                "service", "Java Spring Boot Hello World API",
                "version", "1.0.0",
                "endpoints", new String[]{
                        "GET /actuator/health - Health check",
                        "GET /api/hello - Hello World message",
                        "GET /api/hello/{name} - Personalized hello message",
                        "GET /swagger-ui.html - API documentation"
                }
        ));
    }
}