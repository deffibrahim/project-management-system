package com.pms.util;

public class HtmlUtil {

    private HtmlUtil() {}

    public static String escape(String value) {
        if (value == null) {
            return "";
        }

        StringBuilder result = new StringBuilder(value.length());

        for (char c : value.toCharArray()) {
            switch (c) {
                case '&':  result.append("&amp;");  break;
                case '<':  result.append("&lt;");   break;
                case '>':  result.append("&gt;");   break;
                case '"':  result.append("&quot;"); break;
                case '\'': result.append("&#39;");  break;
                default:   result.append(c);
            }
        }

        return result.toString();
    }
}