
package com.pms.dao;

import com.pms.model.Task;
import com.pms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaskDAO {

    // Builds a Task from the current row of a result set.
    private Task mapTask(ResultSet resultSet) throws SQLException {

        Task task = new Task();

        task.setTaskId(resultSet.getInt("task_id"));
        task.setProjectId(resultSet.getInt("project_id"));
        task.setTitle(resultSet.getString("title"));
        task.setDescription(resultSet.getString("description"));
        task.setAssigneeId(resultSet.getInt("assignee_id"));
        task.setStatus(resultSet.getString("status"));
        task.setPriority(resultSet.getString("priority"));
        task.setDueDate(resultSet.getDate("due_date"));

        return task;
    }

    private String priorityOrDefault(Task task) {

        String priority = task.getPriority();

        return (priority == null || priority.isEmpty())
                ? "MEDIUM"
                : priority;
    }

    // CREATE
    public boolean createTask(Task task) {

        String sql = "INSERT INTO tasks " +
                "(project_id, title, description, assignee_id, status, priority, due_date) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, task.getProjectId());
            statement.setString(2, task.getTitle());
            statement.setString(3, task.getDescription());

            if (task.getAssigneeId() > 0) {
                statement.setInt(4, task.getAssigneeId());
            } else {
                statement.setNull(4, Types.INTEGER);
            }

            statement.setString(5, task.getStatus());
            statement.setString(6, priorityOrDefault(task));
            statement.setDate(7, task.getDueDate());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - Get one task
    public Task getTaskById(int taskId) {

        String sql = "SELECT * FROM tasks WHERE task_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, taskId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {

                    Task task = mapTask(resultSet);

                    return task;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // READ - Get all tasks
    public List<Task> getAllTasks() {

        List<Task> tasks = new ArrayList<>();

        String sql = "SELECT * FROM tasks";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {

                Task task = mapTask(resultSet);

                tasks.add(task);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return tasks;
    }

    // UPDATE
    public boolean updateTask(Task task) {

        String sql = "UPDATE tasks SET " +
                "project_id = ?, title = ?, description = ?, " +
                "assignee_id = ?, status = ?, priority = ?, due_date = ? " +
                "WHERE task_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, task.getProjectId());
            statement.setString(2, task.getTitle());
            statement.setString(3, task.getDescription());

            if (task.getAssigneeId() > 0) {
                statement.setInt(4, task.getAssigneeId());
            } else {
                statement.setNull(4, Types.INTEGER);
            }

            statement.setString(5, task.getStatus());
            statement.setString(6, priorityOrDefault(task));
            statement.setDate(7, task.getDueDate());
            statement.setInt(8, task.getTaskId());

            // Success means the SQL executed without an exception.
            // This also handles saving a task without changing its values.
            statement.executeUpdate();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE
    public boolean deleteTask(int taskId) {

        String sql = "DELETE FROM tasks WHERE task_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, taskId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - Get tasks assigned to a specific user
    public List<Task> getTasksByAssigneeId(int assigneeId) {

        List<Task> tasks = new ArrayList<>();

        String sql = "SELECT * FROM tasks WHERE assignee_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, assigneeId);

            try (ResultSet resultSet = statement.executeQuery()) {

                while (resultSet.next()) {

                    Task task = mapTask(resultSet);

                    tasks.add(task);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return tasks;
    }

    // READ - Get tasks belonging to projects managed by a specific manager
    public List<Task> getTasksByProjectManagerId(int managerId) {

        List<Task> tasks = new ArrayList<>();

        String sql = "SELECT t.* " +
                "FROM tasks t " +
                "JOIN projects p ON t.project_id = p.project_id " +
                "WHERE p.manager_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, managerId);

            try (ResultSet resultSet = statement.executeQuery()) {

                while (resultSet.next()) {

                    Task task = mapTask(resultSet);

                    tasks.add(task);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return tasks;
    }
    // Read tasks belonging to a single project.
    public List<Task> getTasksByProjectId(int projectId) {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT * FROM tasks WHERE project_id = ? ORDER BY task_id DESC";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, projectId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) tasks.add(mapTask(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }

}
