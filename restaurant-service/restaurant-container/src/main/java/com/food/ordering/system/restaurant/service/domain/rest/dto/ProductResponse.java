package com.food.ordering.system.restaurant.service.domain.rest.dto;

import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductResponse {
    private UUID productId;
    private String name;
    private BigDecimal price;
    private Boolean available;
}
