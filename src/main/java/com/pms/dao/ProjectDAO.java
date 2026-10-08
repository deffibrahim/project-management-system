package com.pms.dao;

import com.pms.model.Project;
import com.pms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProjectDAO {

    // CREATE
    public boolean createProject(Project project) {

        String sql = "INSERT INTO projects " +
                "(title, description, start_date, end_date, manager_id, status) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, project.getTitle());
            statement.setString(2, project.getDescription());
            statement.setDate(3, project.getStartDate());
            statement.setDate(4, project.getEndDate());

            if (project.getManagerId() > 0) {
                statement.setInt(5, project.getManagerId());
            } else {
                statement.setNull(5, Types.INTEGER);
            }

            statement.setString(6, project.getStatus());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - Get one project
    public Project getProjectById(int projectId) {

        String sql = "SELECT * FROM projects WHERE project_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, projectId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {
                    Project project = new Project();

                    project.setProjectId(
                            resultSet.getInt("project_id"));
                    project.setTitle(
                            resultSet.getString("title"));
                    project.setDescription(
                            resultSet.getString("description"));
                    project.setStartDate(
                            resultSet.getDate("start_date"));
                    project.setEndDate(
                            resultSet.getDate("end_date"));
                    project.setManagerId(
                            resultSet.getInt("manager_id"));
                    project.setStatus(
                            resultSet.getString("status"));

                    return project;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // READ - Get all projects
    public List<Project> getAllProjects() {

        List<Project> projects = new ArrayList<>();

        String sql = "SELECT * FROM projects";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {

                Project project = new Project();

                project.setProjectId(
                        resultSet.getInt("project_id"));
                project.setTitle(
                        resultSet.getString("title"));
                project.setDescription(
                        resultSet.getString("description"));
                project.setStartDate(
                        resultSet.getDate("start_date"));
                project.setEndDate(
                        resultSet.getDate("end_date"));
                project.setManagerId(
                        resultSet.getInt("manager_id"));
                project.setStatus(
                        resultSet.getString("status"));

                projects.add(project);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return projects;
    }

    // UPDATE
    public boolean updateProject(Project project) {

        String sql = "UPDATE projects SET " +
                "title = ?, description = ?, start_date = ?, " +
                "end_date = ?, manager_id = ?, status = ? " +
                "WHERE project_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, project.getTitle());
            statement.setString(2, project.getDescription());
            statement.setDate(3, project.getStartDate());
            statement.setDate(4, project.getEndDate());

            if (project.getManagerId() > 0) {
                statement.setInt(5, project.getManagerId());
            } else {
                statement.setNull(5, Types.INTEGER);
            }

            statement.setString(6, project.getStatus());
            statement.setInt(7, project.getProjectId());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // DELETE
    public boolean deleteProject(int projectId) {

        String sql = "DELETE FROM projects WHERE project_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, projectId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // READ - Get projects managed by a specific user
    public List<Project> getProjectsByManagerId(int managerId) {

        List<Project> projects = new ArrayList<>();

        String sql = "SELECT * FROM projects WHERE manager_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, managerId);

            try (ResultSet resultSet = statement.executeQuery()) {

                while (resultSet.next()) {

                    Project project = new Project();

                    project.setProjectId(
                            resultSet.getInt("project_id"));
                    project.setTitle(
                            resultSet.getString("title"));
                    project.setDescription(
                            resultSet.getString("description"));
                    project.setStartDate(
                            resultSet.getDate("start_date"));
                    project.setEndDate(
                            resultSet.getDate("end_date"));
                    project.setManagerId(
                            resultSet.getInt("manager_id"));
                    project.setStatus(
                            resultSet.getString("status"));

                    projects.add(project);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return projects;
    }
}