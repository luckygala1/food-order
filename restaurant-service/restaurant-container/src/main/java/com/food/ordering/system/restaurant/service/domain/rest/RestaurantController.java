package com.food.ordering.system.restaurant.service.domain.rest;

import com.food.ordering.system.data.access.restaurant.entity.RestaurantEntity;
import com.food.ordering.system.data.access.restaurant.repository.RestaurantJpaRepository;
import com.food.ordering.system.restaurant.service.domain.rest.dto.ProductResponse;
import com.food.ordering.system.restaurant.service.domain.rest.dto.RestaurantResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping(value = "/restaurants", produces = "application/vnd.api.v1+json")
public class RestaurantController {

    private final RestaurantJpaRepository restaurantJpaRepository;

    public RestaurantController(RestaurantJpaRepository restaurantJpaRepository) {
        this.restaurantJpaRepository = restaurantJpaRepository;
    }

    @GetMapping
    public ResponseEntity<List<RestaurantResponse>> getAllRestaurants() {
        log.info("Fetching all active restaurants");
        List<RestaurantEntity> entities = restaurantJpaRepository.findByRestaurantActiveTrue();
        List<RestaurantResponse> restaurants = groupByRestaurant(entities);
        log.info("Found {} active restaurants", restaurants.size());
        return ResponseEntity.ok(restaurants);
    }

    @GetMapping("/{restaurantId}")
    public ResponseEntity<RestaurantResponse> getRestaurantById(@PathVariable UUID restaurantId) {
        log.info("Fetching restaurant with id: {}", restaurantId);
        List<RestaurantEntity> entities = restaurantJpaRepository.findByRestaurantActiveTrue();
        List<RestaurantEntity> filtered = entities.stream()
                .filter(e -> e.getRestaurantId().equals(restaurantId))
                .collect(Collectors.toList());
        if (filtered.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        RestaurantResponse restaurant = groupByRestaurant(filtered).get(0);
        log.info("Found restaurant: {} with {} products", restaurant.getName(), restaurant.getProducts().size());
        return ResponseEntity.ok(restaurant);
    }

    private List<RestaurantResponse> groupByRestaurant(List<RestaurantEntity> entities) {
        Map<UUID, List<RestaurantEntity>> grouped = entities.stream()
                .collect(Collectors.groupingBy(RestaurantEntity::getRestaurantId));

        return grouped.entrySet().stream().map(entry -> {
            List<RestaurantEntity> restaurantEntities = entry.getValue();
            RestaurantEntity first = restaurantEntities.get(0);

            List<ProductResponse> products = restaurantEntities.stream()
                    .map(e -> ProductResponse.builder()
                            .productId(e.getProductId())
                            .name(e.getProductName())
                            .price(e.getProductPrice())
                            .available(e.getProductAvailable())
                            .build())
                    .collect(Collectors.toList());

            return RestaurantResponse.builder()
                    .restaurantId(first.getRestaurantId())
                    .name(first.getRestaurantName())
                    .active(first.getRestaurantActive())
                    .products(products)
                    .build();
        }).collect(Collectors.toList());
    }
}
