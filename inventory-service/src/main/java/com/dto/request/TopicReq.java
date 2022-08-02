package com.dto.request;

public class TopicReq extends FuelOrderReq{
    private String referenceNumber;

    public TopicReq() {
    }

    public TopicReq(long shedId,short fuelType,double capacity,String referenceNumber) {
        this.referenceNumber = referenceNumber;
        this.shedId = shedId;
        this.fuelType = fuelType;
        this.capacity = capacity;
    }

    public String getReferenceNumber() {
        return referenceNumber;
    }

    public void setReferenceNumber(String referenceNumber) {
        this.referenceNumber = referenceNumber;
    }

    @Override
    public String toString() {
        return "TopicReq{" +
                "referenceNumber='" + referenceNumber + '\'' +
                ", shedId=" + shedId +
                ", fuelType=" + fuelType +
                ", capacity=" + capacity +
                '}';
    }
}
