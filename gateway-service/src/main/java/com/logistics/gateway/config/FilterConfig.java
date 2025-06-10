package com.logistics.gateway.config;

import com.logistics.gateway.filter.JWTAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Configuration class for Gateway filters.
 * This class ensures that custom filters are properly registered as Spring beans.
 */
@Configuration
public class FilterConfig {

    /**
     * Registers the JWT Authentication Filter as a Spring bean.
     * This ensures the filter is available for dependency injection and
     * is automatically applied to all gateway routes.
     * 
     * @return JWTAuthenticationFilter instance
     */
    @Bean
    public JWTAuthenticationFilter jwtAuthenticationFilter() {
        return new JWTAuthenticationFilter();
    }
}