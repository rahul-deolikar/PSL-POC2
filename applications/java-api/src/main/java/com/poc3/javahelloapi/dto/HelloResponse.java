package com.poc3.javahelloapi.dto;

import java.util.Map;

public class HelloResponse {
    private String message;
    private String version;
    private String technology;
    private String timestamp;
    private Map<String, Object> additionalData;

    public HelloResponse() {}

    public HelloResponse(String message, String version, String technology, String timestamp, Map<String, Object> additionalData) {
        this.message = message;
        this.version = version;
        this.technology = technology;
        this.timestamp = timestamp;
        this.additionalData = additionalData;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getTechnology() {
        return technology;
    }

    public void setTechnology(String technology) {
        this.technology = technology;
    }

    public String getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(String timestamp) {
        this.timestamp = timestamp;
    }

    public Map<String, Object> getAdditionalData() {
        return additionalData;
    }

    public void setAdditionalData(Map<String, Object> additionalData) {
        this.additionalData = additionalData;
    }
}