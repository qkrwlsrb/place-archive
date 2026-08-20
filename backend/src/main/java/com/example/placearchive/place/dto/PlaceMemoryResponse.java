package com.example.placearchive.place.dto;

import com.example.placearchive.place.PlaceMemory;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

public record PlaceMemoryResponse(
        Long id,
        Long userId,
        String authorNickname,
        String title,
        String memo,
        BigDecimal latitude,
        BigDecimal longitude,
        String address,
        boolean isPublic,
        LocalDateTime createdAt,
        LocalDateTime updatedAt,
        List<PlaceMemoryImageResponse> images
) {
    public static PlaceMemoryResponse from(PlaceMemory placeMemory) {
        List<PlaceMemoryImageResponse> images = placeMemory.getImages()
                .stream()
                .sorted(Comparator.comparingInt(image -> image.getSortOrder()))
                .map(PlaceMemoryImageResponse::from)
                .toList();

        return new PlaceMemoryResponse(
                placeMemory.getId(),
                placeMemory.getUser().getId(),
                placeMemory.getUser().getNickname(),
                placeMemory.getTitle(),
                placeMemory.getMemo(),
                placeMemory.getLatitude(),
                placeMemory.getLongitude(),
                placeMemory.getAddress(),
                placeMemory.isPublic(),
                placeMemory.getCreatedAt(),
                placeMemory.getUpdatedAt(),
                images
        );
    }
}
