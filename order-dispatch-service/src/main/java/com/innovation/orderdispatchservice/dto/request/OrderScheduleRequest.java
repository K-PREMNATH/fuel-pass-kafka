package com.innovation.orderdispatchservice.dto.request;

/**
 * @Author G.Vageeshan
 * @Version 1.0
 * @since 2022-08-03 12:07 AM Wednesday
 **/
public class OrderScheduleRequest {
    private String orderReferenceNumber;

    public OrderScheduleRequest() {
    }

    public OrderScheduleRequest(String orderReferenceNumber) {
        this.orderReferenceNumber = orderReferenceNumber;
    }

    public String getOrderReferenceNumber() {
        return orderReferenceNumber;
    }

    public void setOrderReferenceNumber(String orderReferenceNumber) {
        this.orderReferenceNumber = orderReferenceNumber;
    }
}
