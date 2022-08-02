package com.dto.request;

public class FuelOrderReq {
    protected long shedId;
    protected short fuelType;
    protected double capacity;

    public FuelOrderReq() {
    }

    public long getShedId() {
        return shedId;
    }

    public void setShedId(long shedId) {
        this.shedId = shedId;
    }

    public short getFuelType() {
        return fuelType;
    }

    public void setFuelType(short fuelType) {
        this.fuelType = fuelType;
    }

    public double getCapacity() {
        return capacity;
    }

    public void setCapacity(double capacity) {
        this.capacity = capacity;
    }
}
