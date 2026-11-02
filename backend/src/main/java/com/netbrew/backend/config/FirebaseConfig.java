package com.netbrew.backend.config;

import com.google.auth.oauth2.AccessToken;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

@Configuration
public class FirebaseConfig {

    @Bean(destroyMethod = "delete")
    public FirebaseApp firebaseApp(FirebaseProperties props) throws IOException {
        FirebaseOptions.Builder options = FirebaseOptions.builder().setCredentials(loadCredentials(props));

        if (StringUtils.hasText(props.projectId())) {
            options.setProjectId(props.projectId());
        }

        return FirebaseApp.initializeApp(options.build());
    }

    @Bean
    public FirebaseAuth firebaseAuth(FirebaseApp app) {
        return FirebaseAuth.getInstance(app);
    }

    private GoogleCredentials loadCredentials(FirebaseProperties props) throws IOException {

        // If JSON content is put in environment variables
        if (StringUtils.hasText(props.credentialsJson())) {
            try (InputStream in = new ByteArrayInputStream(
                    props.credentialsJson().getBytes(StandardCharsets.UTF_8))) {
                return GoogleCredentials.fromStream(in);
            }
        }

        // If using path to file service account
        if (StringUtils.hasText(props.credentialsPath())) {
            try (InputStream in = Files.newInputStream(Path.of(props.credentialsPath()))) {
                return GoogleCredentials.fromStream(in);
            }
        }

        // Authenticate information not found
        if (!StringUtils.hasText(props.projectId())) {
            throw new IllegalStateException(
                    "Set FIREBASE_PROJECT_ID (and FIREBASE_CREDENTIALS_PATH or FIREBASE_CREDENTIALS_JSON, or use the Firebase Auth emulator)"
            );
        }

        return GoogleCredentials.create(new AccessToken("emulator", null));
    }
}
