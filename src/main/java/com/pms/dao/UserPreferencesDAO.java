package com.pms.dao;

import com.pms.model.UserPreferences;
import com.pms.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserPreferencesDAO {

    /**
     * Returns the user's saved preferences, or the defaults
     * (dashboard landing page, completed tasks visible) when none exist.
     */
    public UserPreferences getPreferences(int userId) {

        UserPreferences prefs = new UserPreferences();
        prefs.setUserId(userId);

        String sql = "SELECT landing_page, hide_completed FROM user_preferences WHERE user_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    String landing = rs.getString("landing_page");

                    if (UserPreferences.isValidLanding(landing)) {
                        prefs.setLandingPage(landing);
                    }

                    prefs.setHideCompleted(rs.getBoolean("hide_completed"));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return prefs;
    }

    public boolean savePreferences(UserPreferences prefs) {

        String sql = "INSERT INTO user_preferences (user_id, landing_page, hide_completed) "
                + "VALUES (?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE landing_page = VALUES(landing_page), "
                + "hide_completed = VALUES(hide_completed)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, prefs.getUserId());
            statement.setString(2, prefs.getLandingPage());
            statement.setBoolean(3, prefs.isHideCompleted());

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
