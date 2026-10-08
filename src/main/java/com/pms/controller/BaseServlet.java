package com.pms.controller;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import com.pms.model.User;

/**
 * Base servlet providing common utilities for all application servlets.
 * Handles CSRF token validation and session checks.
 */
public abstract class BaseServlet extends HttpServlet {

    /**
     * Validates that a request has a valid CSRF token.
     * The token is stored in the session attribute "csrfToken" and must be present
     * as a request parameter "csrfToken" for POST operations.
     */
    protected boolean validateCsrf(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return false;
        }
        String sessionToken = (String) session.getAttribute("csrfToken");
        String requestToken = req.getParameter("csrfToken");
        return sessionToken != null && sessionToken.equals(requestToken);
    }

    /**
     * Returns the logged‑in {@link User} object stored in the session, or {@code null}.
     */
    protected User getLoggedInUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (session != null) ? (User) session.getAttribute("user") : null;
    }

    /**
     * Sends a 403 Forbidden response when CSRF validation fails.
     */
    protected void denyCsrf(HttpServletResponse resp) throws IOException {
        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
    }
}
