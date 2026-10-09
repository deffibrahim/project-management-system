(function () {
  "use strict";
  var sidebar = document.getElementById("sidebar");
  var toggle = document.getElementById("sidebarToggle");
  var overlay = document.getElementById("sidebarOverlay");
  if (!sidebar || !toggle || !overlay) return;
  function closeSidebar() {
    sidebar.classList.remove("open");
    overlay.classList.remove("visible");
    toggle.setAttribute("aria-expanded", "false");
  }
  toggle.addEventListener("click", function () {
    var opening = !sidebar.classList.contains("open");
    sidebar.classList.toggle("open", opening);
    overlay.classList.toggle("visible", opening);
    toggle.setAttribute("aria-expanded", String(opening));
  });
  overlay.addEventListener("click", closeSidebar);
  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") closeSidebar();
  });
  sidebar.querySelectorAll("a").forEach(function (link) {
    link.addEventListener("click", closeSidebar);
  });
})();
