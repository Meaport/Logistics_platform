package com.logistics.auth.config;

import com.logistics.auth.entity.Permission;
import com.logistics.auth.entity.Role;
import com.logistics.auth.entity.User;
import com.logistics.auth.repository.PermissionRepository;
import com.logistics.auth.repository.RoleRepository;
import com.logistics.auth.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.Set;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private PermissionRepository permissionRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        initializePermissions();
        initializeRoles();
        initializeUsers();
    }

    private void initializePermissions() {
        if (permissionRepository.count() == 0) {
            // User permissions
            permissionRepository.save(new Permission("USER_READ", "Read user data", "USER", "READ"));
            permissionRepository.save(new Permission("USER_WRITE", "Write user data", "USER", "WRITE"));
            permissionRepository.save(new Permission("USER_DELETE", "Delete user data", "USER", "DELETE"));

            // Transport permissions
            permissionRepository.save(new Permission("TRANSPORT_READ", "Read transport data", "TRANSPORT", "READ"));
            permissionRepository.save(new Permission("TRANSPORT_WRITE", "Write transport data", "TRANSPORT", "WRITE"));
            permissionRepository.save(new Permission("TRANSPORT_DELETE", "Delete transport data", "TRANSPORT", "DELETE"));

            // Admin permissions
            permissionRepository.save(new Permission("ADMIN_ALL", "Full admin access", "ADMIN", "ALL"));
        }
    }

    private void initializeRoles() {
        if (roleRepository.count() == 0) {
            // USER role
            Role userRole = new Role("USER", "Standard user role");
            Set<Permission> userPermissions = new HashSet<>();
            userPermissions.add(permissionRepository.findByName("USER_READ").orElse(null));
            userRole.setPermissions(userPermissions);
            roleRepository.save(userRole);

            // MANAGER role
            Role managerRole = new Role("MANAGER", "Manager role with extended permissions");
            Set<Permission> managerPermissions = new HashSet<>();
            managerPermissions.add(permissionRepository.findByName("USER_READ").orElse(null));
            managerPermissions.add(permissionRepository.findByName("USER_WRITE").orElse(null));
            managerPermissions.add(permissionRepository.findByName("TRANSPORT_READ").orElse(null));
            managerPermissions.add(permissionRepository.findByName("TRANSPORT_WRITE").orElse(null));
            managerRole.setPermissions(managerPermissions);
            roleRepository.save(managerRole);

            // ADMIN role
            Role adminRole = new Role("ADMIN", "Administrator role with full permissions");
            Set<Permission> adminPermissions = new HashSet<>(permissionRepository.findAll());
            adminRole.setPermissions(adminPermissions);
            roleRepository.save(adminRole);
        }
    }

    private void initializeUsers() {
        if (userRepository.count() == 0) {
            // Create admin user
            User admin = new User("admin", "admin@logistics.com", passwordEncoder.encode("admin123"));
            admin.setFirstName("System");
            admin.setLastName("Administrator");
            Set<Role> adminRoles = new HashSet<>();
            adminRoles.add(roleRepository.findByName("ADMIN").orElse(null));
            admin.setRoles(adminRoles);
            userRepository.save(admin);

            // Create test user
            User testUser = new User("testuser", "test@logistics.com", passwordEncoder.encode("test123"));
            testUser.setFirstName("Test");
            testUser.setLastName("User");
            Set<Role> userRoles = new HashSet<>();
            userRoles.add(roleRepository.findByName("USER").orElse(null));
            testUser.setRoles(userRoles);
            userRepository.save(testUser);
        }
    }
}