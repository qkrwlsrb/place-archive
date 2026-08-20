package com.example.placearchive.place;

import com.example.placearchive.common.ApiResponse;
import com.example.placearchive.common.PageResponse;
import com.example.placearchive.place.dto.PlaceMemoryCreateRequest;
import com.example.placearchive.place.dto.PlaceMemoryResponse;
import com.example.placearchive.place.dto.PlaceMemoryUpdateRequest;
import com.example.placearchive.security.UserPrincipal;
import jakarta.validation.Valid;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/place-memories")
public class PlaceMemoryController {

    private final PlaceMemoryService placeMemoryService;

    public PlaceMemoryController(PlaceMemoryService placeMemoryService) {
        this.placeMemoryService = placeMemoryService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<PlaceMemoryResponse> create(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody PlaceMemoryCreateRequest request
    ) {
        return ApiResponse.success(placeMemoryService.create(principal.id(), request));
    }

    @GetMapping("/me")
    public ApiResponse<PageResponse<PlaceMemoryResponse>> findMine(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ApiResponse.success(placeMemoryService.findMine(principal.id(), pageable(page, size)));
    }

    @GetMapping("/public")
    public ApiResponse<PageResponse<PlaceMemoryResponse>> findPublic(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ApiResponse.success(placeMemoryService.findPublic(keyword, pageable(page, size)));
    }

    @GetMapping("/{id}")
    public ApiResponse<PlaceMemoryResponse> findOne(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long id
    ) {
        return ApiResponse.success(placeMemoryService.findOne(principal.id(), id));
    }

    @PatchMapping("/{id}")
    public ApiResponse<PlaceMemoryResponse> update(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long id,
            @Valid @RequestBody PlaceMemoryUpdateRequest request
    ) {
        return ApiResponse.success(placeMemoryService.update(principal.id(), id, request));
    }

    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long id
    ) {
        placeMemoryService.delete(principal.id(), id);
        return ApiResponse.success();
    }

    private Pageable pageable(int page, int size) {
        int normalizedPage = Math.max(page, 0);
        int normalizedSize = Math.min(Math.max(size, 1), 50);
        return PageRequest.of(normalizedPage, normalizedSize, Sort.by(Sort.Direction.DESC, "createdAt"));
    }
}
