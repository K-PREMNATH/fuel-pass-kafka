package com.innovation.orderdispatchservice.dto.response;

/**
 * @Author G.Vageeshan
 * @Version 1.0
 * @since 2022-08-03 12:46 AM Wednesday
 **/
public class CommonResponse {
    private int statusCode;
    private String message;

    public CommonResponse() {
    }

    public CommonResponse(int statusCode, String message) {
        this.statusCode = statusCode;
        this.message = message;
    }

    public int getStatusCode() {
        return statusCode;
    }

    public void setStatusCode(int statusCode) {
        this.statusCode = statusCode;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
