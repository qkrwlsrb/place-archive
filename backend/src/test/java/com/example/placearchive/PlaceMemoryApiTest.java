package com.example.placearchive;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class PlaceMemoryApiTest {

    @Autowired
    MockMvc mockMvc;

    @Autowired
    ObjectMapper objectMapper;

    @Test
    void authenticatedUserCreatesAndReadsOwnPlaceMemoryWithImages() throws Exception {
        // Catches: authenticated creation not bound to current user or image URL metadata not persisted.
        String token = signupAndLogin("owner-read@example.com", "OwnerRead");

        long id = createMemory(token, "Tokyo Tower", "Night view", true);

        mockMvc.perform(get("/api/place-memories/{id}", id)
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.title").value("Tokyo Tower"))
                .andExpect(jsonPath("$.data.images[0].imageUrl").value("https://cdn.example.com/tokyo.jpg"));

        mockMvc.perform(get("/api/place-memories/me")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.content[0].title").value("Tokyo Tower"))
                .andExpect(jsonPath("$.data.page").value(0))
                .andExpect(jsonPath("$.data.size").value(20))
                .andExpect(jsonPath("$.data.totalElements").value(1));
    }

    @Test
    void onlyAuthorCanUpdateOrDeletePlaceMemory() throws Exception {
        // Catches: ownership check missing from mutation endpoints.
        String ownerToken = signupAndLogin("owner-authz@example.com", "OwnerAuthz");
        String otherToken = signupAndLogin("other-authz@example.com", "OtherAuthz");
        long id = createMemory(ownerToken, "Kyoto Cafe", "Matcha memory", false);

        mockMvc.perform(patch("/api/place-memories/{id}", id)
                        .header("Authorization", "Bearer " + otherToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "title": "Changed by other"
                                }
                                """))
                .andExpect(status().isForbidden());

        mockMvc.perform(delete("/api/place-memories/{id}", id)
                        .header("Authorization", "Bearer " + otherToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error.code").value("FORBIDDEN"));
    }

    @Test
    void publicListAndKeywordSearchReturnOnlyPublicMatchingMemories() throws Exception {
        // Catches: public feed leaking private records or search ignoring keyword filtering.
        String token = signupAndLogin("search@example.com", "SearchUser");
        createMemory(token, "Osaka Castle", "A public sakura walk", true);
        createMemory(token, "Private Home", "sakura private note", false);

        mockMvc.perform(get("/api/place-memories/public")
                        .param("keyword", "sakura"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.content.length()").value(1))
                .andExpect(jsonPath("$.data.content[0].title").value("Osaka Castle"))
                .andExpect(jsonPath("$.data.totalElements").value(1));
    }

    @Test
    void publicListSupportsPaginationMetadata() throws Exception {
        // Catches: list endpoints returning unbounded arrays without page metadata.
        String token = signupAndLogin("paging@example.com", "PagingUser");
        createMemory(token, "First public memory", "paging-only first", true);
        createMemory(token, "Second public memory", "paging-only second", true);

        mockMvc.perform(get("/api/place-memories/public")
                        .param("keyword", "paging-only")
                        .param("page", "0")
                        .param("size", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.content.length()").value(1))
                .andExpect(jsonPath("$.data.page").value(0))
                .andExpect(jsonPath("$.data.size").value(1))
                .andExpect(jsonPath("$.data.totalElements").value(2))
                .andExpect(jsonPath("$.data.totalPages").value(2))
                .andExpect(jsonPath("$.data.hasNext").value(true));
    }

    private String signupAndLogin(String email, String nickname) throws Exception {
        mockMvc.perform(post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "%s",
                                  "password": "password123",
                                  "nickname": "%s"
                                }
                                """.formatted(email, nickname)))
                .andExpect(status().isCreated());

        String body = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "%s",
                                  "password": "password123"
                                }
                                """.formatted(email)))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        return objectMapper.readTree(body).path("data").path("accessToken").asText();
    }

    private long createMemory(String token, String title, String memo, boolean isPublic) throws Exception {
        String body = mockMvc.perform(post("/api/place-memories")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "title": "%s",
                                  "memo": "%s",
                                  "latitude": 35.658581,
                                  "longitude": 139.745433,
                                  "address": "4 Chome-2-8 Shibakoen, Minato City, Tokyo",
                                  "isPublic": %s,
                                  "images": [
                                    {
                                      "imageUrl": "https://cdn.example.com/tokyo.jpg",
                                      "originalFilename": "tokyo.jpg",
                                      "contentType": "image/jpeg",
                                      "sizeBytes": 2048
                                    }
                                  ]
                                }
                                """.formatted(title, memo, isPublic)))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();

        JsonNode data = objectMapper.readTree(body).path("data");
        return data.path("id").asLong();
    }
}
