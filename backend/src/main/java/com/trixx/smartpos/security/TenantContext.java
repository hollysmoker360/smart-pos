package com.trixx.smartpos.security;

public class TenantContext {
    private static final ThreadLocal<String> CURRENT_TENANT = new ThreadLocal<>();
    private static final ThreadLocal<String> CURRENT_BRANCH = new ThreadLocal<>();

    public static void setTenantId(String tenantId) {
        CURRENT_TENANT.set(tenantId);
    }

    public static String getTenantId() {
        return CURRENT_TENANT.get();
    }

    public static void setBranchId(String branchId) {
        CURRENT_BRANCH.set(branchId);
    }

    public static String getBranchId() {
        return CURRENT_BRANCH.get();
    }

    public static void clear() {
        CURRENT_TENANT.remove();
        CURRENT_BRANCH.remove();
    }
}
