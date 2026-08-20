package com.example.placearchive.place;

import com.example.placearchive.common.BusinessException;
import com.example.placearchive.common.ErrorCode;
import com.example.placearchive.common.PageResponse;
import com.example.placearchive.place.dto.PlaceMemoryCreateRequest;
import com.example.placearchive.place.dto.PlaceMemoryImageRequest;
import com.example.placearchive.place.dto.PlaceMemoryResponse;
import com.example.placearchive.place.dto.PlaceMemoryUpdateRequest;
import com.example.placearchive.user.User;
import com.example.placearchive.user.UserRepository;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class PlaceMemoryService {

    private final PlaceMemoryRepository placeMemoryRepository;
    private final UserRepository userRepository;

    public PlaceMemoryService(PlaceMemoryRepository placeMemoryRepository, UserRepository userRepository) {
        this.placeMemoryRepository = placeMemoryRepository;
        this.userRepository = userRepository;
    }

    @Transactional
    public PlaceMemoryResponse create(Long userId, PlaceMemoryCreateRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.UNAUTHORIZED));
        PlaceMemory placeMemory = new PlaceMemory(
                user,
                request.title(),
                request.memo(),
                request.latitude(),
                request.longitude(),
                request.address(),
                request.isPublic()
        );
        buildImages(request.images()).forEach(placeMemory::addImage);
        return PlaceMemoryResponse.from(placeMemoryRepository.save(placeMemory));
    }

    @Transactional(readOnly = true)
    public PageResponse<PlaceMemoryResponse> findMine(Long userId, Pageable pageable) {
        Page<PlaceMemory> page = placeMemoryRepository.findByUserId(userId, pageable);
        return PageResponse.from(page.map(PlaceMemoryResponse::from));
    }

    @Transactional(readOnly = true)
    public PlaceMemoryResponse findOne(Long userId, Long placeMemoryId) {
        PlaceMemory placeMemory = findById(placeMemoryId);
        if (!placeMemory.isPublic() && !placeMemory.isOwnedBy(userId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }
        return PlaceMemoryResponse.from(placeMemory);
    }

    @Transactional(readOnly = true)
    public PageResponse<PlaceMemoryResponse> findPublic(String keyword, Pageable pageable) {
        String normalizedKeyword = StringUtils.hasText(keyword) ? keyword.trim() : null;
        Page<PlaceMemory> page = placeMemoryRepository.searchPublic(normalizedKeyword, pageable);
        List<PlaceMemoryResponse> content = loadImagesKeepingPageOrder(page)
                .stream()
                .map(PlaceMemoryResponse::from)
                .toList();
        return new PageResponse<>(
                content,
                page.getNumber(),
                page.getSize(),
                page.getTotalElements(),
                page.getTotalPages(),
                page.hasNext()
        );
    }

    @Transactional
    public PlaceMemoryResponse update(Long userId, Long placeMemoryId, PlaceMemoryUpdateRequest request) {
        PlaceMemory placeMemory = findById(placeMemoryId);
        verifyOwner(placeMemory, userId);

        placeMemory.update(
                request.title(),
                request.memo(),
                request.latitude(),
                request.longitude(),
                request.address(),
                request.isPublic()
        );
        if (request.images() != null) {
            placeMemory.replaceImages(buildImages(request.images()));
        }
        return PlaceMemoryResponse.from(placeMemory);
    }

    @Transactional
    public void delete(Long userId, Long placeMemoryId) {
        PlaceMemory placeMemory = findById(placeMemoryId);
        verifyOwner(placeMemory, userId);
        placeMemoryRepository.delete(placeMemory);
    }

    private PlaceMemory findById(Long placeMemoryId) {
        return placeMemoryRepository.findByIdWithImages(placeMemoryId)
                .orElseThrow(() -> new BusinessException(ErrorCode.PLACE_MEMORY_NOT_FOUND));
    }

    private void verifyOwner(PlaceMemory placeMemory, Long userId) {
        if (!placeMemory.isOwnedBy(userId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }
    }

    private List<PlaceMemory> loadImagesKeepingPageOrder(Page<PlaceMemory> page) {
        List<Long> ids = page.getContent().stream().map(PlaceMemory::getId).toList();
        if (ids.isEmpty()) {
            return List.of();
        }
        Map<Long, PlaceMemory> byId = placeMemoryRepository.findAllByIdInWithImages(ids)
                .stream()
                .collect(Collectors.toMap(PlaceMemory::getId, Function.identity()));
        return ids.stream()
                .map(byId::get)
                .sorted(Comparator.comparing(memory -> ids.indexOf(memory.getId())))
                .toList();
    }

    private List<PlaceMemoryImage> buildImages(List<PlaceMemoryImageRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            return List.of();
        }
        List<PlaceMemoryImage> images = new ArrayList<>();
        for (int i = 0; i < requests.size(); i++) {
            PlaceMemoryImageRequest request = requests.get(i);
            images.add(new PlaceMemoryImage(
                    request.imageUrl(),
                    request.originalFilename(),
                    request.contentType(),
                    request.sizeBytes(),
                    i
            ));
        }
        return images;
    }
}
