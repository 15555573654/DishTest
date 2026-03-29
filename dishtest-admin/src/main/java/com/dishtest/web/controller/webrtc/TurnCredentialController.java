package com.dishtest.web.controller.webrtc;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.util.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.dishtest.common.annotation.Anonymous;
import com.dishtest.common.core.domain.AjaxResult;
import com.dishtest.common.utils.SecurityUtils;

/**
 * WebRTC TURN 临时凭证下发
 */
@RestController
@RequestMapping("/webrtc/turn")
public class TurnCredentialController
{
    private static final String HMAC_SHA1 = "HmacSHA1";

    @Value("${webrtc.turn.enabled:false}")
    private boolean enabled;

    @Value("${webrtc.turn.secret:}")
    private String secret;

    @Value("${webrtc.turn.realm:}")
    private String realm;

    @Value("${webrtc.turn.ttlSeconds:3600}")
    private long ttlSeconds;

    @Value("${webrtc.turn.urls:}")
    private String urls;

    @Anonymous
    @GetMapping("/credentials")
    public AjaxResult getCredentials(@RequestParam(value = "username", required = false) String requestedUsername)
    {
        if (!enabled)
        {
            return AjaxResult.error("TURN 凭证下发未启用");
        }
        if (secret == null || secret.trim().isEmpty())
        {
            return AjaxResult.error("TURN 密钥未配置");
        }
        List<String> turnUrls = parseUrls(urls);
        if (turnUrls.isEmpty())
        {
            return AjaxResult.error("TURN 地址未配置");
        }

        String userId = resolveUsername(requestedUsername);
        if (!StringUtils.hasText(userId))
        {
            return AjaxResult.error("用户名不能为空");
        }
        long expiresAt = Instant.now().getEpochSecond() + ttlSeconds;
        String username = expiresAt + ":" + userId;
        String credential = generateCredential(username, secret);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("username", username);
        data.put("credential", credential);
        data.put("ttlSeconds", ttlSeconds);
        data.put("expiresAt", expiresAt);
        data.put("realm", realm);
        data.put("urls", turnUrls);

        Map<String, Object> iceServer = new LinkedHashMap<>();
        iceServer.put("urls", turnUrls);
        iceServer.put("username", username);
        iceServer.put("credential", credential);
        data.put("iceServer", iceServer);

        return AjaxResult.success(data);
    }

    private String resolveUsername(String requestedUsername)
    {
        if (StringUtils.hasText(requestedUsername))
        {
            return requestedUsername.trim();
        }
        try
        {
            return SecurityUtils.getUsername();
        }
        catch (Exception ignored)
        {
            return null;
        }
    }

    private List<String> parseUrls(String urlConfig)
    {
        return Arrays.stream(urlConfig.split(","))
                .map(String::trim)
                .filter(value -> !value.isEmpty())
                .collect(Collectors.toList());
    }

    private String generateCredential(String username, String secretKey)
    {
        try
        {
            Mac mac = Mac.getInstance(HMAC_SHA1);
            SecretKeySpec keySpec = new SecretKeySpec(secretKey.getBytes(StandardCharsets.UTF_8), HMAC_SHA1);
            mac.init(keySpec);
            byte[] digest = mac.doFinal(username.getBytes(StandardCharsets.UTF_8));
            return java.util.Base64.getEncoder().encodeToString(digest);
        }
        catch (Exception e)
        {
            throw new IllegalStateException("生成 TURN 凭证失败", e);
        }
    }
}
