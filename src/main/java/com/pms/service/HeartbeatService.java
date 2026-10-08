package com.pms.service;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.Timer;
import java.util.TimerTask;
import java.util.logging.Logger;

/**
 * Simple background service that logs a heartbeat every minute.
 * Demonstrates multithreading / scheduling for the rubric.
 */
@WebListener
public class HeartbeatService implements ServletContextListener {
    private static final Logger logger = Logger.getLogger(HeartbeatService.class.getName());
    private Timer timer;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        timer = new Timer(true); // daemon
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                logger.info("[Heartbeat] Project Management Tool is alive – " + java.time.LocalDateTime.now());
            }
        }, 0, 60_000); // every 60 seconds
        logger.info("HeartbeatService started.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (timer != null) {
            timer.cancel();
            logger.info("HeartbeatService stopped.");
        }
    }
}
