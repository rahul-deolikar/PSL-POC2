package com.teamcity.cicd.model;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Hello World response model")
public record HelloResponse(
        @Schema(description = "Hello message", example = "Hello World from Java Spring Boot!")
        String message,
        
        @Schema(description = "API version", example = "1.0.0")
        String version,
        
        @Schema(description = "Response timestamp", example = "2023-12-01T10:30:00")
        String timestamp,
        
        @Schema(description = "Technology stack", example = "Java + Spring Boot")
        String technology
) {}