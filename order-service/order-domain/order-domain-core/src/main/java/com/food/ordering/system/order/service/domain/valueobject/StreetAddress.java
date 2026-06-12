package com.food.ordering.system.order.service.domain.valueobject;

import java.util.Objects;
import java.util.UUID;

public class StreetAddress {

    private final UUID uuid;
    private final String street;
    private final String doorNumber;
    private final String recipientName;
    private final String phone;


    public StreetAddress(UUID uuid, String street, String doorNumber, String recipientName, String phone) {
        this.uuid = uuid;
        this.street = street;
        this.doorNumber = doorNumber;
        this.recipientName = recipientName;
        this.phone = phone;
    }

    public UUID getUuid() {
        return uuid;
    }

    public String getStreet() {
        return street;
    }

    public String getDoorNumber() {
        return doorNumber;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public String getPhone() {
        return phone;
    }


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        StreetAddress that = (StreetAddress) o;
        return Objects.equals(street, that.street) && Objects.equals(doorNumber, that.doorNumber)
                && Objects.equals(recipientName, that.recipientName) && Objects.equals(phone, that.phone);
    }

    @Override
    public int hashCode() {
        return Objects.hash(street, doorNumber, recipientName, phone);
    }
}
