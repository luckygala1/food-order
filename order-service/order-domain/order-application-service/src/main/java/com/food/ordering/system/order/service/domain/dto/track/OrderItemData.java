package com.food.ordering.system.order.service.domain.dto.track;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.UUID;

@AllArgsConstructor
@Getter
@Builder
public class OrderItemData {

    @NotNull
    private final UUID productId;

    private final String productName;

    @NotNull
    private final BigDecimal price;

    @NotNull
    private final Integer quantity;

    @NotNull
    private final BigDecimal subTotal;
}
