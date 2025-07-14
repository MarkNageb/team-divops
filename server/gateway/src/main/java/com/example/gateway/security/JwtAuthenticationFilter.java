package com.example.gateway.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.http.HttpHeaders;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.List;

@Component("JwtFilter")
public class JwtAuthenticationFilter implements org.springframework.cloud.gateway.filter.GatewayFilter, org.springframework.core.Ordered {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();

        // Skip auth endpoints
        if (request.getURI().getPath().startsWith("/auth") ||
                request.getURI().getPath().startsWith("/users/register") ||
                request.getURI().getPath().startsWith("/v3/api-docs") ||
                request.getURI().getPath().startsWith("/swagger-ui")) {
            return chain.filter(exchange);
        }

        List<String> authHeaders = request.getHeaders().getOrEmpty(HttpHeaders.AUTHORIZATION);
        if (authHeaders.isEmpty() || !authHeaders.get(0).startsWith("Bearer ")) {
            exchange.getResponse().setStatusCode(org.springframework.http.HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }
        String token = authHeaders.get(0).substring(7);
        try {
            jwtUtil.validate(token);
        } catch (Exception e) {
            exchange.getResponse().setStatusCode(org.springframework.http.HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }
        return chain.filter(exchange);
    }

    @Override
    public int getOrder() {
        return -1; // before Netty routing
    }
}