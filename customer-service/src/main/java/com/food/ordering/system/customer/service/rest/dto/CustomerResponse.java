package com.food.ordering.system.customer.service.rest.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.util.UUID;

@AllArgsConstructor
@Getter
@Builder
public class CustomerResponse {
    private final UUID id;
    private final String username;
    private final String firstName;
    private final String lastName;
}
