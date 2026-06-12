package com.food.ordering.system.restaurant.service.domain.rest.dto;

import lombok.*;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RestaurantResponse {
    private UUID restaurantId;
    private String name;
    private Boolean active;
    private List<ProductResponse> products;
}
