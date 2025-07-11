package com.poc3.javahelloapi.dto;

public class HelloRequest {
    private String name;

    public HelloRequest() {}

    public HelloRequest(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}