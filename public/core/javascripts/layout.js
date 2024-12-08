
function closePanel(panelId) {
  document.getElementById(panelId).style.display = "none";

  document.getElementById("arrow1").style.display = "none";
  document.getElementById("arrow2").style.display = "none";
  document.getElementById("arrow3").style.display = "none";

  const pool1 = document.getElementById("pool1").style.display !== "none";
  const pool2 = document.getElementById("pool2").style.display !== "none";
  const pool3 = document.getElementById("pool3").style.display !== "none";

  const visiblePanels = [pool1, pool2, pool3].filter(Boolean).length;
  if (visiblePanels === 1) {
    if (pool1) {
      document.querySelector("#pool1 .close-btn").style.display = "none";
    }
    if (pool2) {
      document.querySelector("#pool2 .close-btn").style.display = "none";
    }
    if (pool3) {
      document.querySelector("#pool3 .close-btn").style.display = "none";
    }
  }

  adjustLayout();
}

function togglePanel(panelId) {
  const panel = document.getElementById(panelId);
  const pool1 = document.getElementById("pool1");
  const pool2 = document.getElementById("pool2");
  const pool3 = document.getElementById("pool3");
  const arrow1 = document.getElementById("arrow1");
  const arrow2 = document.getElementById("arrow2");
  const arrow3 = document.getElementById("arrow3");

  if (window.matchMedia("(max-width: 768px)").matches) {
    pool1.style.display = "none";
    pool2.style.display = "none";
    pool3.style.display = "none";

    panel.style.display = "block";

    if (arrow1) arrow1.style.display = "none";
    if (arrow2) arrow2.style.display = "none";
    if (arrow3) arrow3.style.display = "none";
  } else {
    const pool1Visible = window.getComputedStyle(pool1).display !== "none";
    const pool2Visible = window.getComputedStyle(pool2).display !== "none";
    const pool3Visible = window.getComputedStyle(pool3).display !== "none";

    const panelVisible = window.getComputedStyle(panel).display !== "none";

    if (!panelVisible) {
      panel.style.display = "block";
    } else {
      panel.style.display = "none";
    }

    const visiblePanels = [pool1, pool2, pool3].filter(Boolean).length;
    if (visiblePanels !== 1) {
      if (pool1) {
        document.querySelector("#pool1 .close-btn").style.display = "block";
      }
      if (pool2) {
        document.querySelector("#pool2 .close-btn").style.display = "block";
      }
      if (pool3) {
        document.querySelector("#pool3 .close-btn").style.display = "block";
      }
    }
    if (pool1Visible || pool2Visible || pool3Visible) {
      arrow1.style.display = "none";
      arrow2.style.display = "none";
      arrow3.style.display = "none";
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
    //  document.getElementById('arrow-btn').style.display = 'none'
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

$(document).ready(function() {
  $(".tab-button").click(function() {
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
});
