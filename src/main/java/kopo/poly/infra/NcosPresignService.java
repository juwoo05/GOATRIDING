// src/main/java/kopo/poly/infra/NcosPresignService.java
package kopo.poly.infra;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.model.ObjectCannedACL;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;

import java.net.URI;
import java.net.URL;
import java.time.Duration;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class NcosPresignService {

    @Value("${cloud.ncp.storage.endpoint}")
    private String endpoint;

    @Value("${cloud.ncp.storage.region}")
    private String region;

    @Value("${cloud.ncp.storage.bucket}")
    private String bucket;

    @Value("${cloud.ncp.storage.access-key}")
    private String accessKey;

    @Value("${cloud.ncp.storage.secret-key}")
    private String secretKey;

    @Value("${app.public.base}")
    private String publicBase; // https://<bucket>.kr.object.ncloudstorage.com

    public PresignedUpload createUploadUrl(String folder, String contentType) {
        String key = folder + "/" + UUID.randomUUID() + guessExt(contentType);
        log.info("[NcosPresignService] createUploadUrl folder={}, contentType={}, key={}", folder, contentType, key);

        AwsBasicCredentials creds = AwsBasicCredentials.create(accessKey, secretKey);
        try (S3Presigner presigner = S3Presigner.builder()
                .endpointOverride(URI.create(endpoint))
                .region(Region.of(region))
                .credentialsProvider(StaticCredentialsProvider.create(creds))
                .build()) {

            PutObjectRequest put = PutObjectRequest.builder()
                    .bucket(bucket)
                    .key(key)
                    .contentType(contentType)
                    .acl(ObjectCannedACL.PUBLIC_READ) // CORS에 x-amz-acl 허용 필요
                    .build();

            PutObjectPresignRequest presign = PutObjectPresignRequest.builder()
                    .signatureDuration(Duration.ofMinutes(10))
                    .putObjectRequest(put)
                    .build();

            PresignedPutObjectRequest pre = presigner.presignPutObject(presign);
            URL url = pre.url();

            String base = publicBase.endsWith("/") ? publicBase.substring(0, publicBase.length() - 1) : publicBase;
            String publicUrl = base + "/" + key;

            log.info("[NcosPresignService] presigned uploadUrl={}, publicUrl={}", url, publicUrl);
            return new PresignedUpload(url.toString(), publicUrl, key, contentType);
        }
    }

    private String guessExt(String ct) {
        if (ct == null) return "";
        if (ct.equalsIgnoreCase("image/png"))  return ".png";
        if (ct.equalsIgnoreCase("image/jpeg")) return ".jpg";
        if (ct.equalsIgnoreCase("image/webp")) return ".webp";
        return "";
    }

    public record PresignedUpload(String uploadUrl, String publicUrl, String key, String contentType) {}
}
