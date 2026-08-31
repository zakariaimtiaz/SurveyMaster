package com.imtiaz.model;

public class SecUser {
    private Long id;
    private Long version;
    private String username;
    private String email;
    private boolean enabled;
    private String password;
    private boolean accountExpired;
    private boolean accountLocked;
    private boolean passwordExpired;
    private String defaultTargetUrl;
    private String resetToken;
    private java.sql.Timestamp resetTokenExpiry;

    public SecUser() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getVersion() { return version; }
    public void setVersion(Long version) { this.version = version; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public boolean isAccountExpired() { return accountExpired; }
    public void setAccountExpired(boolean accountExpired) { this.accountExpired = accountExpired; }

    public boolean isAccountLocked() { return accountLocked; }
    public void setAccountLocked(boolean accountLocked) { this.accountLocked = accountLocked; }

    public boolean isPasswordExpired() { return passwordExpired; }
    public void setPasswordExpired(boolean passwordExpired) { this.passwordExpired = passwordExpired; }

    public String getDefaultTargetUrl() { return defaultTargetUrl; }
    public void setDefaultTargetUrl(String defaultTargetUrl) { this.defaultTargetUrl = defaultTargetUrl; }

    public String getResetToken() { return resetToken; }
    public void setResetToken(String resetToken) { this.resetToken = resetToken; }

    public java.sql.Timestamp getResetTokenExpiry() { return resetTokenExpiry; }
    public void setResetTokenExpiry(java.sql.Timestamp resetTokenExpiry) { this.resetTokenExpiry = resetTokenExpiry; }
}
