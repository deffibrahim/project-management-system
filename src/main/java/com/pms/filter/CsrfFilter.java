package com.pms.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

@WebFilter("/*")
public class CsrfFilter implements Filter {

    private static final String CSRF_TOKEN =
            "csrfToken";

    private final SecureRandom secureRandom =
            new SecureRandom();

    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest =
                (HttpServletRequest) request;

        HttpServletResponse httpResponse =
                (HttpServletResponse) response;

        String method = httpRequest.getMethod();

        /*
         * Login is excluded because the user does not have
         * an authenticated session yet.
         */
        String path = httpRequest.getRequestURI()
                .substring(
                        httpRequest.getContextPath().length()
                );

        if ("/login".equals(path)) {
            chain.doFilter(request, response);
            return;
        }

        /*
         * Only protect state-changing requests.
         */
        if ("POST".equalsIgnoreCase(method)
                || "PUT".equalsIgnoreCase(method)
                || "PATCH".equalsIgnoreCase(method)
                || "DELETE".equalsIgnoreCase(method)) {

            HttpSession session =
                    httpRequest.getSession(false);

            if (session == null) {
                httpResponse.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Invalid session."
                );
                return;
            }

            String sessionToken =
                    (String) session.getAttribute(CSRF_TOKEN);

            String requestToken =
                    httpRequest.getParameter(CSRF_TOKEN);

            if (sessionToken == null
                    || requestToken == null
                    || !MessageDigest.isEqual(
                    sessionToken.getBytes(StandardCharsets.UTF_8),
                    requestToken.getBytes(StandardCharsets.UTF_8))) {

                httpResponse.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Invalid CSRF token."
                );
                return;
            }
        }

        /*
         * Generate a token for authenticated sessions.
         */
        HttpSession session =
                httpRequest.getSession(false);

        if (session != null
                && session.getAttribute(CSRF_TOKEN) == null) {

            byte[] randomBytes = new byte[32];
            secureRandom.nextBytes(randomBytes);

            String token = Base64.getUrlEncoder()
                    .withoutPadding()
                    .encodeToString(randomBytes);

            session.setAttribute(CSRF_TOKEN, token);
        }

        chain.doFilter(request, response);
    }
}