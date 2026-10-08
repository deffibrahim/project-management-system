package com.pms.model;

public class SystemSetting {

    private int settingId;
    private String settingName;
    private String settingValue;

    public SystemSetting() {
    }

    public SystemSetting(int settingId, String settingName, String settingValue) {
        this.settingId = settingId;
        this.settingName = settingName;
        this.settingValue = settingValue;
    }

    public int getSettingId() {
        return settingId;
    }

    public void setSettingId(int settingId) {
        this.settingId = settingId;
    }

    public String getSettingName() {
        return settingName;
    }

    public void setSettingName(String settingName) {
        this.settingName = settingName;
    }

    public String getSettingValue() {
        return settingValue;
    }

    public void setSettingValue(String settingValue) {
        this.settingValue = settingValue;
    }
}