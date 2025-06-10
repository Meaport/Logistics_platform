package com.logistics.gateway.filter;

import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

@Component
public class LoggingGatewayFilterFactory extends AbstractGatewayFilterFactory<LoggingGatewayFilterFactory.Config> {

    public LoggingGatewayFilterFactory() {
        super(Config.class);
    }

    @Override
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            if (config.isEnabled()) {
                String requestPath = exchange.getRequest().getURI().getPath();
                String method = exchange.getRequest().getMethod().name();
                String remoteAddress = exchange.getRequest().getRemoteAddress() != null ? 
                    exchange.getRequest().getRemoteAddress().getAddress().getHostAddress() : "unknown";
                
                System.out.println(String.format("[GATEWAY] %s %s from %s", method, requestPath, remoteAddress));
            }
            
            return chain.filter(exchange).then(
                Mono.fromRunnable(() -> {
                    if (config.isEnabled()) {
                        int statusCode = exchange.getResponse().getStatusCode() != null ? 
                            exchange.getResponse().getStatusCode().value() : 0;
                        System.out.println(String.format("[GATEWAY] Response: %d", statusCode));
                    }
                })
            );
        };
    }

    public static class Config {
        private boolean enabled = true;
        
        public boolean isEnabled() {
            return enabled;
        }
        
        public void setEnabled(boolean enabled) {
            this.enabled = enabled;
        }
    }
}