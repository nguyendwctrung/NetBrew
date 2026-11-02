package com.netbrew.backend.model.enums;

import java.util.EnumSet;
import java.util.Set;

public enum OrderStatus {
    PENDING,
    CONFIRMED,
    PREPARING,
    READY,
    DELIVERING,
    COMPLETED,
    CANCELLED;

    public Set<OrderStatus> allowNext() {
        return switch (this) {
            case PENDING -> EnumSet.of(CONFIRMED, CANCELLED);
            case CONFIRMED -> EnumSet.of(PREPARING, CANCELLED);
            case PREPARING -> EnumSet.of(READY, CANCELLED);
            case READY -> EnumSet.of(DELIVERING, CANCELLED);
            case DELIVERING -> EnumSet.of(COMPLETED, CANCELLED);
            case COMPLETED, CANCELLED -> EnumSet.noneOf(OrderStatus.class);
        };
    }

    public boolean canTransitionTo(OrderStatus next) {
        return allowNext().contains(next);
    }

    public boolean isCancellableByCustomer() {
        return this == PENDING || this == CONFIRMED || this == PREPARING || this == READY;
    }

    public boolean isTerminal() {
        return this == COMPLETED || this == CANCELLED;
    }
}