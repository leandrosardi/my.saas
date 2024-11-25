function closePanel(panelId) {
  document.getElementById(panelId).style.display = "none";
  adjustLayout();
}

function togglePanel(panelId, arrowID) {
  const panel = document.getElementById(panelId);
  const pool1 = document.getElementById("pool1");
  const pool2 = document.getElementById("pool2");
  const pool3 = document.getElementById("pool3");

  if (window.matchMedia("(max-width: 768px)").matches) {
    pool1.style.display = "none";
    pool2.style.display = "none";
    pool3.style.display = "none";

    panel.style.display = "block";
  } else {
    const panelVisible = window.getComputedStyle(panel).display !== "none";

    if (!panelVisible) {
      panel.style.display = "block";
    } else {
      panel.style.display = "none";
    }
    const arrowElement = document.getElementById(arrowID);

    if (arrowElement) {
      if (arrowElement.innerHTML.includes("fa-arrow-right")) {
        arrowElement.innerHTML = '<i class="fa-solid fa-arrow-left"></i>';
      } else if (arrowElement.innerHTML.includes("fa-arrow-left")) {
        arrowElement.innerHTML = '<i class="fa-solid fa-arrow-right"></i>';
      }
    }
  }
  adjustLayout();
}

function openPanel(panelId) {
  const panel = document.getElementById(panelId);
  panel.style.display = "block";
  adjustLayout();
}
function adjustLayout() {
  const sidebar = document.getElementById("pool1");
  const chatSection = document.getElementById("pool2");
  const thirdSection = document.getElementById("pool3");

  if (
    sidebar.style.display !== "none" &&
    chatSection.style.display !== "none" &&
    thirdSection.style.display !== "none"
  ) {
    sidebar.style.width = "25%";
    chatSection.style.width = "50%";
    thirdSection.style.width = "25%";
  } else if (
    sidebar.style.display !== "none" &&
    chatSection.style.display !== "none"
  ) {
    sidebar.style.width = "30%";
    chatSection.style.width = "70%";
  } else if (
    chatSection.style.display !== "none" &&
    thirdSection.style.display !== "none"
  ) {
    chatSection.style.width = "70%";
    thirdSection.style.width = "30%";
  } else if (
    sidebar.style.display !== "none" &&
    thirdSection.style.display !== "none"
  ) {
    sidebar.style.width = "50%";
    thirdSection.style.width = "50%";
  } else {
    if (sidebar.style.display !== "none") sidebar.style.width = "100%";
    if (chatSection.style.display !== "none") chatSection.style.width = "100%";
    if (thirdSection.style.display !== "none")
      thirdSection.style.width = "100%";
  }
}

$(document).ready(function () {
  $(".tab-button").click(function () {
    const button = this;
    const tabContainer = button.closest(".tab-container");
    const tabId = button.getAttribute("data-tab");

    tabContainer.querySelectorAll(".tab-button").forEach((btn) => {
      btn.classList.remove("active");
    });

    button.classList.add("active");

    tabContainer.querySelectorAll(".tab-content").forEach((content) => {
      content.classList.remove("active");
    });

    tabContainer.querySelector(`#${tabId}`).classList.add("active");
  });

  document
    .getElementById("darkModeButton")
    .addEventListener("click", function () {
      document.body.classList.toggle("dark-mode");

      // Change the button text based on the mode
      if (document.body.classList.contains("dark-mode")) {
        this.innerHTML = '<div class="ball"></div> Light Mode'; // Ball is now inside the button while changing text
      } else {
        this.innerHTML = '<div class="ball"></div> Dark Mode'; // Ball is now inside the button while changing text
      }
    });
});
