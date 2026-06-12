package com.food.ordering.system.customer.service.rest;

import com.food.ordering.system.customer.service.entity.CustomerEntity;
import com.food.ordering.system.customer.service.repository.CustomerJpaRepository;
import com.food.ordering.system.customer.service.rest.dto.CustomerResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping(value = "/customers", produces = "application/vnd.api.v1+json")
public class CustomerController {

    private final CustomerJpaRepository customerJpaRepository;

    public CustomerController(CustomerJpaRepository customerJpaRepository) {
        this.customerJpaRepository = customerJpaRepository;
    }

    @GetMapping
    public ResponseEntity<List<CustomerResponse>> getAllCustomers() {
        log.info("Fetching all customers");
        List<CustomerResponse> customers = customerJpaRepository.findAll().stream()
                .map(entity -> CustomerResponse.builder()
                        .id(entity.getId())
                        .username(entity.getUsername())
                        .firstName(entity.getFirstName())
                        .lastName(entity.getLastName())
                        .build())
                .collect(Collectors.toList());
        log.info("Found {} customers", customers.size());
        return ResponseEntity.ok(customers);
    }
}
