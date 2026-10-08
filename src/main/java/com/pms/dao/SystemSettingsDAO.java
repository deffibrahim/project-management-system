package com.pms.dao;

import com.pms.model.SystemSetting;
import com.pms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SystemSettingsDAO {

    public boolean createSetting(SystemSetting setting) {

        String sql = "INSERT INTO system_settings (setting_name, setting_value) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, setting.getSettingName());
            ps.setString(2, setting.getSettingValue());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public SystemSetting getSettingById(int settingId) {

        String sql = "SELECT * FROM system_settings WHERE setting_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, settingId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                SystemSetting setting = new SystemSetting();

                setting.setSettingId(rs.getInt("setting_id"));
                setting.setSettingName(rs.getString("setting_name"));
                setting.setSettingValue(rs.getString("setting_value"));

                return setting;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<SystemSetting> getAllSettings() {

        List<SystemSetting> settings = new ArrayList<>();

        String sql = "SELECT * FROM system_settings";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                SystemSetting setting = new SystemSetting();

                setting.setSettingId(rs.getInt("setting_id"));
                setting.setSettingName(rs.getString("setting_name"));
                setting.setSettingValue(rs.getString("setting_value"));

                settings.add(setting);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return settings;
    }

    public boolean updateSetting(SystemSetting setting) {

        String sql = "UPDATE system_settings SET setting_name = ?, setting_value = ? WHERE setting_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, setting.getSettingName());
            ps.setString(2, setting.getSettingValue());
            ps.setInt(3, setting.getSettingId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteSetting(int settingId) {

        String sql = "DELETE FROM system_settings WHERE setting_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, settingId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Returns the value stored under the given setting name,
     * or null if the setting does not exist.
     */
    public String getValue(String settingName) {

        String sql = "SELECT setting_value FROM system_settings WHERE setting_name = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, settingName);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("setting_value");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Inserts the setting, or updates it if the name already exists.
     */
    public boolean saveValue(String settingName, String settingValue) {

        String sql = "INSERT INTO system_settings (setting_name, setting_value) VALUES (?, ?) "
                + "ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, settingName);
            ps.setString(2, settingValue);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
