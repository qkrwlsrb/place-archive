package com.example.placearchive.place.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;

public record PlaceMemoryUpdateRequest(
        @Size(max = 120) String title,
        String memo,
        @DecimalMin("-90.0") @DecimalMax("90.0") BigDecimal latitude,
        @DecimalMin("-180.0") @DecimalMax("180.0") BigDecimal longitude,
        @Size(max = 255) String address,
        Boolean isPublic,
        @Valid List<PlaceMemoryImageRequest> images
) {
}
