package com.pms.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Creates database connections.
 *
 * Connection settings are read from environment variables so that no
 * credentials need to be stored in the source code / GitHub repository:
 *
 *   PMS_DB_URL       (default: jdbc:mysql://localhost:3306/pms_db)
 *   PMS_DB_USER      (default: root)
 *   PMS_DB_PASSWORD  (default: empty - the XAMPP default)
 *
 * If the variables are not set, the defaults above are used, so the project
 * works out of the box with a fresh local XAMPP / MySQL installation.
 */
public class DBConnection {

    private static final String URL =
            setting("PMS_DB_URL", "jdbc:mysql://localhost:3306/pms_db");
    private static final String USER =
            setting("PMS_DB_USER", "root");
    private static final String PASSWORD =
            setting("PMS_DB_PASSWORD", "");

    private static String setting(String name, String defaultValue) {
        String value = System.getenv(name);
        if (value == null) {
            value = System.getProperty(name);
        }
        return (value == null) ? defaultValue : value;
    }

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
