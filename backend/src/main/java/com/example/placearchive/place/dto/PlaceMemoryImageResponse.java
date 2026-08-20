package com.example.placearchive.place.dto;

import com.example.placearchive.place.PlaceMemoryImage;

public record PlaceMemoryImageResponse(
        Long id,
        String imageUrl,
        String originalFilename,
        String contentType,
        Long sizeBytes,
        int sortOrder
) {
    public static PlaceMemoryImageResponse from(PlaceMemoryImage image) {
        return new PlaceMemoryImageResponse(
                image.getId(),
                image.getImageUrl(),
                image.getOriginalFilename(),
                image.getContentType(),
                image.getSizeBytes(),
                image.getSortOrder()
        );
    }
}
