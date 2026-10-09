(function () {
    "use strict";

    // Same behaviour as the theme toggle on every other dashboard page:
    // icon-only button (moon in light mode, sun in dark mode), shared
    // "pms-theme" localStorage key.
    var button = document.getElementById("themeToggle");
    var storageKey = "pms-theme";
    var body = document.body;

    function readTheme() {
        try {
            var saved = window.localStorage.getItem(storageKey);
            return saved === "dark" || saved === "light" ? saved : "light";
        } catch (error) {
            return "light";
        }
    }

    function applyTheme(theme) {
        theme = theme === "dark" ? "dark" : "light";
        body.setAttribute("data-theme", theme);

        if (button) {
            button.innerHTML = theme === "dark" ? "&#9728;" : "&#9790;";
            button.setAttribute("aria-label",
                theme === "dark" ? "Switch to light mode" : "Switch to dark mode");
        }
    }

    applyTheme(readTheme());

    if (button) {
        button.addEventListener("click", function () {
            var next = body.getAttribute("data-theme") === "dark" ? "light" : "dark";
            applyTheme(next);
            try {
                window.localStorage.setItem(storageKey, next);
            } catch (error) {
                // Theme still works for this page when storage is blocked.
            }
        });
    }
})();
