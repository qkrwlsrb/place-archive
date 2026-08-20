package com.example.placearchive.place;

import com.example.placearchive.user.User;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "place_memories")
public class PlaceMemory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 120)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String memo;

    @Column(nullable = false, precision = 10, scale = 7)
    private BigDecimal latitude;

    @Column(nullable = false, precision = 10, scale = 7)
    private BigDecimal longitude;

    @Column(nullable = false, length = 255)
    private String address;

    @Column(name = "is_public", nullable = false)
    private boolean isPublic;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "placeMemory", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PlaceMemoryImage> images = new ArrayList<>();

    protected PlaceMemory() {
    }

    public PlaceMemory(User user, String title, String memo, BigDecimal latitude, BigDecimal longitude, String address, boolean isPublic) {
        this.user = user;
        this.title = title;
        this.memo = memo;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.isPublic = isPublic;
    }

    @PrePersist
    void prePersist() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public void update(String title, String memo, BigDecimal latitude, BigDecimal longitude, String address, Boolean isPublic) {
        if (title != null) {
            this.title = title;
        }
        if (memo != null) {
            this.memo = memo;
        }
        if (latitude != null) {
            this.latitude = latitude;
        }
        if (longitude != null) {
            this.longitude = longitude;
        }
        if (address != null) {
            this.address = address;
        }
        if (isPublic != null) {
            this.isPublic = isPublic;
        }
    }

    public void replaceImages(List<PlaceMemoryImage> newImages) {
        images.clear();
        newImages.forEach(this::addImage);
    }

    public void addImage(PlaceMemoryImage image) {
        image.attachTo(this);
        images.add(image);
    }

    public boolean isOwnedBy(Long userId) {
        return user.getId().equals(userId);
    }

    public Long getId() {
        return id;
    }

    public User getUser() {
        return user;
    }

    public String getTitle() {
        return title;
    }

    public String getMemo() {
        return memo;
    }

    public BigDecimal getLatitude() {
        return latitude;
    }

    public BigDecimal getLongitude() {
        return longitude;
    }

    public String getAddress() {
        return address;
    }

    public boolean isPublic() {
        return isPublic;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public List<PlaceMemoryImage> getImages() {
        return images;
    }
}
