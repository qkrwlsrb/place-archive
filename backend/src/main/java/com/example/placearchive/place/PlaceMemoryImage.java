package com.example.placearchive.place;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "place_memory_images")
public class PlaceMemoryImage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "place_memory_id", nullable = false)
    private PlaceMemory placeMemory;

    @Column(nullable = false, length = 500)
    private String imageUrl;

    @Column(length = 255)
    private String originalFilename;

    @Column(length = 80)
    private String contentType;

    private Long sizeBytes;

    @Column(nullable = false)
    private int sortOrder;

    protected PlaceMemoryImage() {
    }

    public PlaceMemoryImage(String imageUrl, String originalFilename, String contentType, Long sizeBytes, int sortOrder) {
        this.imageUrl = imageUrl;
        this.originalFilename = originalFilename;
        this.contentType = contentType;
        this.sizeBytes = sizeBytes;
        this.sortOrder = sortOrder;
    }

    void attachTo(PlaceMemory placeMemory) {
        this.placeMemory = placeMemory;
    }

    public Long getId() {
        return id;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public String getOriginalFilename() {
        return originalFilename;
    }

    public String getContentType() {
        return contentType;
    }

    public Long getSizeBytes() {
        return sizeBytes;
    }

    public int getSortOrder() {
        return sortOrder;
    }
}
