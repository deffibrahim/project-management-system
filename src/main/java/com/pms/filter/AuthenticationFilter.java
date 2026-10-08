
package com.pms.filter;

import com.pms.model.User;

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

@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest =
                (HttpServletRequest) request;

        HttpServletResponse httpResponse =
                (HttpServletResponse) response;

        String path = httpRequest.getRequestURI()
                .substring(
                        httpRequest.getContextPath().length()
                );

        HttpSession session =
                httpRequest.getSession(false);

        User user = null;

        if (session != null) {
            user = (User) session.getAttribute("user");
        }

        boolean loggedIn = user != null;

        /*
         * Public resources.
         */
        boolean publicPage =
                path.equals("/index.html")
                        || path.equals("/login")
                        || path.equals("/logout")
                        || path.startsWith("/css/");

        if (publicPage) {
            chain.doFilter(request, response);
            return;
        }

        /*
         * Everything else requires authentication.
         */
        if (!loggedIn) {
            httpResponse.sendRedirect(
                    httpRequest.getContextPath()
                            + "/index.html"
            );
            return;
        }

        String role = user.getRole();

        /*
         * ADMIN-only resources.
         *
         * Protect both servlet endpoints and JSP pages
         * from direct URL access.
         */
        boolean adminOnlyResource =
                path.startsWith("/users")
                        || path.equals("/settings/create")
                        || path.equals("/settings/edit")
                        || path.equals("/settings/update")
                        || path.equals("/settings/delete")
                        || path.equals("/dashboard/users.jsp")
                        || path.equals("/dashboard/create-user.jsp")
                        || path.equals("/dashboard/edit-user.jsp")
                        || path.equals("/dashboard/edit-setting.jsp");

        if (adminOnlyResource) {

            if (!"ADMIN".equals(role)) {
                httpResponse.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Access denied."
                );
                return;
            }
        }

        /*
         * ADMIN dashboard.
         *
         * Direct JSP access redirects to the servlet
         * so dashboard data is loaded correctly.
         */
        if (path.equals("/dashboard/admin.jsp")) {

            if (!"ADMIN".equals(role)) {
                httpResponse.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Access denied."
                );
                return;
            }

            httpResponse.sendRedirect(
                    httpRequest.getContextPath()
                            + "/dashboard/admin"
            );
            return;
        }

        /*
         * PROJECT_MANAGER dashboard.
         */
        if (path.equals("/dashboard/project-manager.jsp")
                || path.equals("/dashboard/project-manager")) {

            if (!"PROJECT_MANAGER".equals(role)) {
                httpResponse.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Access denied."
                );
                return;
            }

            if (path.equals("/dashboard/project-manager.jsp")) {
                httpResponse.sendRedirect(
                        httpRequest.getContextPath()
                                + "/dashboard/project-manager"
                );
                return;
            }
        }

        /*
         * TEAM_MEMBER dashboard.
         */
        if (path.equals("/dashboard/team-member.jsp")
                || path.equals("/dashboard/team-member")) {

            if (!"TEAM_MEMBER".equals(role)) {
                httpResponse.sendError(
                        HttpServletResponse.SC_FORBIDDEN,
                        "Access denied."
                );
                return;
            }

            if (path.equals("/dashboard/team-member.jsp")) {
                httpResponse.sendRedirect(
                        httpRequest.getContextPath()
                                + "/dashboard/team-member"
                );
                return;
            }
        }

        /*
         * Continue to the requested resource.
         *
         * Individual CRUD servlets must continue to
         * perform their own authorization checks.
         */
        chain.doFilter(request, response);
    }
}
