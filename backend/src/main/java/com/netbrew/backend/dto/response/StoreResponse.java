package com.netbrew.backend.dto.response;

import com.netbrew.backend.model.entity.StoreInfo;

import java.math.BigDecimal;
import java.time.LocalTime;

public record StoreResponse(String name, String phone, String address, BigDecimal latitude, BigDecimal longitude, LocalTime openingTime, LocalTime closingTime, int deliveryRadiusMeters, long deliveryFee, boolean acceptingOrders) {
    public static StoreResponse from(StoreInfo s) {
        return new StoreResponse(
                s.getName(),
                s.getPhone(),
                s.getAddress(),
                s.getLatitude(),
                s.getLongitude(),
                s.getOpeningTime(),
                s.getClosingTime(),
                s.getDeliveryRadiusMeters(),
                s.getDeliveryFee(),
                s.isAcceptingOrders()
        );
    }
}
