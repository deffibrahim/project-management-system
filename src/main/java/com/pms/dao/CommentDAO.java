package com.pms.dao;

import com.pms.model.Comment;
import com.pms.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class CommentDAO {

    private Comment map(ResultSet rs) throws SQLException {

        Comment comment = new Comment();

        comment.setCommentId(rs.getInt("comment_id"));
        comment.setTaskId(rs.getInt("task_id"));
        comment.setUserId(rs.getInt("user_id"));   // 0 when NULL
        comment.setAuthorName(rs.getString("author_name"));
        comment.setAuthorRole(rs.getString("author_role"));
        comment.setBody(rs.getString("body"));
        comment.setCreatedAt(rs.getTimestamp("created_at"));

        return comment;
    }

    private static final String SELECT =
            "SELECT c.comment_id, c.task_id, c.user_id, c.body, c.created_at, " +
            "u.name AS author_name, u.role AS author_role " +
            "FROM task_comments c " +
            "LEFT JOIN users u ON c.user_id = u.user_id ";

    // Oldest first, so a conversation reads top to bottom.
    public List<Comment> getCommentsByTaskId(int taskId) {

        List<Comment> comments = new ArrayList<>();

        String sql = SELECT + "WHERE c.task_id = ? ORDER BY c.created_at ASC, c.comment_id ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, taskId);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    comments.add(map(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return comments;
    }

    public Comment getCommentById(int commentId) {

        String sql = SELECT + "WHERE c.comment_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, commentId);

            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return map(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean addComment(Comment comment) {

        String sql = "INSERT INTO task_comments (task_id, user_id, body) VALUES (?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, comment.getTaskId());

            if (comment.getUserId() > 0) {
                statement.setInt(2, comment.getUserId());
            } else {
                statement.setNull(2, Types.INTEGER);
            }

            statement.setString(3, comment.getBody());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteComment(int commentId) {

        String sql = "DELETE FROM task_comments WHERE comment_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, commentId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
