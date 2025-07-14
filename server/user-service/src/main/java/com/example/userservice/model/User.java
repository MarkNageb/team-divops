package com.example.userservice.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.UuidGenerator;

import java.time.LocalDate;

@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue
    @UuidGenerator
    @Column(updatable = false, nullable = false)
    private String id;

    @Getter
    @Column(name = "email", nullable = false, unique = true)
    String email;

    @Getter
    @Column(name = "first_name", nullable = false)
    String firstName;

    @Getter
    @Column(name = "last_name", nullable = false)
    String lastName;


    @Getter
    @Setter
    @Column(name = "password", nullable = false)
    String password;


    protected User() {
        // no-args constructor required by JPA spec
        // this one is protected since it shouldn’t be used directly
    }

    public User(String email, String firstName, String lastName, LocalDate birthdate, String password, String role, boolean enabled) {
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.password = password;
    }
}
