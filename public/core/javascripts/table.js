function closePanel(panelId) {
  document.getElementById(panelId).style.display = "none";
  adjustLayout();
}

function togglePanel(panelId, arrowID) {
  const panel = document.getElementById(panelId);
  const pool2 = document.getElementById("pool2");
  const pool3 = document.getElementById("pool3");

  if (window.matchMedia("(max-width: 768px)").matches) {
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
  const chatSection = document.getElementById("pool2");
  const thirdSection = document.getElementById("pool3");

  if (
    chatSection.style.display === "none" ||
    window.getComputedStyle(chatSection).display === "none"
  ) {
    // If pool2 is hidden, make pool3 take full width
    thirdSection.style.width = "100%";
    thirdSection.style.display = "block"; // Ensure pool3 is visible
  } else if (
    thirdSection.style.display === "none" ||
    window.getComputedStyle(thirdSection).display === "none"
  ) {
    // If pool3 is hidden, make pool2 take full width
    chatSection.style.width = "100%";
    chatSection.style.display = "block"; // Ensure pool2 is visible
  } else {
    // Adjust widths for both pool2 and pool3 when both are visible
    chatSection.style.width = "70%";
    thirdSection.style.width = "30%";

    // Ensure both sections are visible
    chatSection.style.display = "block";
    thirdSection.style.display = "block";
  }
}

document.querySelectorAll(".tab-button").forEach((button) => {
  button.addEventListener("click", () => {
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
});

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

  $(".expand-pool2").on("click", function () {
    $(".pool2").addClass("expanded").removeClass("collapsed");
    $(".pool3").addClass("collapsed").removeClass("expanded");
  });

  $(".expand-pool3").on("click", function () {
    $(".pool2").addClass("collapsed").removeClass("expanded");
    $(".pool3").addClass("expanded").removeClass("collapsed");
  });
  // Optional: Automatically collapse sections on small screens
  function checkWindowSize() {
    if ($(window).width() <= 1200) {
      // Ensure pool2 and pool3 have proper widths
      $("#pool2").css("width", "70%");
      $("#pool3").css("width", "30%");
    } else {
      // Reset to default behavior for larger screens
      $("#pool2").css("width", "70%"); // or any other desired width
      $("#pool3").css("width", "30%");
    }
  }

  // Check window size on load and resize
  checkWindowSize();
  $(window).resize(function () {
    checkWindowSize();
  });
});
