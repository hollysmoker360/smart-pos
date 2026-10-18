package com.trixx.smartpos.security;

import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtProvider jwtProvider;

    public JwtAuthenticationFilter(JwtProvider jwtProvider) {
        this.jwtProvider = jwtProvider;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String correlationId = request.getHeader("X-Correlation-ID");
        if (correlationId == null || correlationId.isBlank()) {
            correlationId = UUID.randomUUID().toString();
        }
        response.setHeader("X-Correlation-ID", correlationId);

        try {
            String jwt = parseJwt(request);
            if (jwt != null && jwtProvider.validateJwtToken(jwt)) {
                String username = jwtProvider.getUsernameFromJwtToken(jwt);
                Claims claims = jwtProvider.getClaimsFromToken(jwt);

                String tenantId = claims.get("tenantId", String.class);
                String branchId = claims.get("branchId", String.class);
                String role = claims.get("role", String.class);

                if (tenantId != null) TenantContext.setTenantId(tenantId);
                if (branchId != null) TenantContext.setBranchId(branchId);

                List<SimpleGrantedAuthority> authorities = role != null ?
                        List.of(new SimpleGrantedAuthority(role)) : Collections.emptyList();

                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        username, null, authorities);
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                SecurityContextHolder.getContext().setAuthentication(authentication);
            } else {
                // Check direct X-Tenant-ID and X-Branch-ID headers for unauthenticated/guest session initializations
                String headerTenant = request.getHeader("X-Tenant-ID");
                String headerBranch = request.getHeader("X-Branch-ID");
                if (headerTenant != null) TenantContext.setTenantId(headerTenant);
                if (headerBranch != null) TenantContext.setBranchId(headerBranch);
            }
        } catch (Exception e) {
            logger.error("Cannot set user authentication: {}", e);
        }

        try {
            filterChain.doFilter(request, response);
        } finally {
            TenantContext.clear();
        }
    }

    private String parseJwt(HttpServletRequest request) {
        String headerAuth = request.getHeader("Authorization");
        if (headerAuth != null && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }
        return null;
    }
}
