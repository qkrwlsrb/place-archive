package com.example.placearchive.place.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record PlaceMemoryImageRequest(
        @NotBlank @Size(max = 500) String imageUrl,
        @Size(max = 255) String originalFilename,
        @Size(max = 80) String contentType,
        Long sizeBytes
) {
}
