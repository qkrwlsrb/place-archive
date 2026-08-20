package com.example.placearchive.auth;

import com.example.placearchive.auth.dto.AuthResponse;
import com.example.placearchive.auth.dto.LoginRequest;
import com.example.placearchive.auth.dto.SignupRequest;
import com.example.placearchive.common.BusinessException;
import com.example.placearchive.common.ErrorCode;
import com.example.placearchive.security.JwtTokenProvider;
import com.example.placearchive.security.UserPrincipal;
import com.example.placearchive.user.User;
import com.example.placearchive.user.UserRepository;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            AuthenticationManager authenticationManager,
            JwtTokenProvider jwtTokenProvider
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Transactional
    public User signup(SignupRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new BusinessException(ErrorCode.DUPLICATED_EMAIL);
        }
        User user = new User(request.email(), passwordEncoder.encode(request.password()), request.nickname());
        return userRepository.save(user);
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.email(), request.password())
            );
            UserPrincipal principal = (UserPrincipal) authentication.getPrincipal();
            String accessToken = jwtTokenProvider.createAccessToken(principal);
            return new AuthResponse(accessToken, "Bearer", jwtTokenProvider.expiresInSeconds());
        } catch (BadCredentialsException exception) {
            throw new BusinessException(ErrorCode.INVALID_CREDENTIALS);
        }
    }
}
