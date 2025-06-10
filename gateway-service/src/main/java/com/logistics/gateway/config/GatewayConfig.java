package com.logistics.gateway.config;

import com.logistics.gateway.filter.AuthenticationGatewayFilterFactory;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GatewayConfig {

    @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                // Health check route
                .route("health-check", r -> r
                        .path("/health")
                        .uri("http://localhost:8080/actuator/health"))
                
                // Fallback route for service discovery
                .route("service-discovery-fallback", r -> r
                        .path("/services/**")
                        .filters(f -> f.stripPrefix(1))
                        .uri("lb://discovery-server"))
                .build();
    }
}