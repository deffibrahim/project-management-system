package com.pms.controller;

import com.pms.dao.CommentDAO;
import com.pms.dao.TaskDAO;
import com.pms.model.Comment;
import com.pms.model.Task;
import com.pms.model.User;
import com.pms.util.AppSettings;
import com.pms.util.TaskAccess;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * POST /tasks/comment   action=add | delete
 *
 * Anyone who may open the task can comment on it.
 * A comment can be deleted by its author or by an admin.
 */
@WebServlet("/tasks/comment")
public class CommentServlet extends BaseServlet {

    private static final int MAX_LENGTH = 1000;

    private final TaskDAO taskDAO = new TaskDAO();
    private final CommentDAO commentDAO = new CommentDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(request.getContextPath() + "/tasks");
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        if (!validateCsrf(request)) {
            denyCsrf(response);
            return;
        }

        User user = getLoggedInUser(request);

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addComment(request, response, user);
        } else if ("delete".equals(action)) {
            deleteComment(request, response, user);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action.");
        }
    }

    private void addComment(HttpServletRequest request,
                            HttpServletResponse response,
                            User user)
            throws IOException {

        int taskId;

        try {
            taskId = Integer.parseInt(request.getParameter("taskId"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Valid task id is required.");
            return;
        }

        Task task = taskDAO.getTaskById(taskId);

        if (task == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found.");
            return;
        }

        if (!TaskAccess.canAccess(user, task)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to comment on this task.");
            return;
        }

        // Admin can switch this off for team members in Settings > System.
        if ("TEAM_MEMBER".equals(user.getRole())
                && !AppSettings.isMembersCanComment()) {

            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Commenting is turned off for team members.");
            return;
        }

        String body = request.getParameter("body");
        body = body == null ? "" : body.trim();

        if (body.isEmpty()) {
            redirect(request, response, taskId, "error", "Please write a comment first.");
            return;
        }

        if (body.length() > MAX_LENGTH) {
            redirect(request, response, taskId, "error",
                    "Comments can be at most " + MAX_LENGTH + " characters.");
            return;
        }

        Comment comment = new Comment();
        comment.setTaskId(taskId);
        comment.setUserId(user.getUserId());
        comment.setBody(body);

        if (!commentDAO.addComment(comment)) {
            redirect(request, response, taskId, "error", "Could not save your comment. Please try again.");
            return;
        }

        redirect(request, response, taskId, null, null);
    }

    private void deleteComment(HttpServletRequest request,
                               HttpServletResponse response,
                               User user)
            throws IOException {

        int commentId;

        try {
            commentId = Integer.parseInt(request.getParameter("commentId"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Valid comment id is required.");
            return;
        }

        Comment comment = commentDAO.getCommentById(commentId);

        if (comment == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Comment not found.");
            return;
        }

        boolean isAuthor = comment.getUserId() == user.getUserId();
        boolean isAdmin = "ADMIN".equals(user.getRole());

        if (!isAuthor && !isAdmin) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "You can only delete your own comments.");
            return;
        }

        // The user must still be allowed to see the task (admins always are).
        Task task = taskDAO.getTaskById(comment.getTaskId());

        if (!isAdmin && !TaskAccess.canAccess(user, task)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to change this task's comments.");
            return;
        }

        commentDAO.deleteComment(commentId);

        redirect(request, response, comment.getTaskId(), null, null);
    }

    private void redirect(HttpServletRequest request,
                          HttpServletResponse response,
                          int taskId,
                          String kind,
                          String message)
            throws IOException {

        String url = request.getContextPath() + "/tasks/view?id=" + taskId;

        if (kind != null) {
            url += "&" + kind + "="
                    + URLEncoder.encode(message, StandardCharsets.UTF_8);
        }

        response.sendRedirect(url + "#comments");
    }
}
