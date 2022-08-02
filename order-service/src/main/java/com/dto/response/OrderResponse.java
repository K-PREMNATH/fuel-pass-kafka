package com.dto.response;

public class OrderResponse extends GeneralResponse{
    private String referenceNumber;

    public OrderResponse() {
    }

    public String getReferenceNumber() {
        return referenceNumber;
    }

    public void setReferenceNumber(String referenceNumber) {
        this.referenceNumber = referenceNumber;
    }
}
