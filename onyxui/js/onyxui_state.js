// This is the base state class, it is not to be used directly

function NanoStateClass() {}

NanoStateClass.prototype.key = null;
NanoStateClass.prototype.layoutRendered = false;
NanoStateClass.prototype.contentRendered = false;
NanoStateClass.prototype.mapInitialised = false;
NanoStateClass.prototype.windowState = null;
NanoStateClass.prototype.isDragging = false;
NanoStateClass.prototype.dragOffset = [0, 0];

NanoStateClass.prototype.isCurrent = function () {
  return NanoStateManager.getCurrentState() == this;
};

NanoStateClass.prototype.onAdd = function (previousState) {
  // Do not add code here, add it to the 'default' state (onyxui_defaut.js) or create a new state and override this function

  NanoBaseCallbacks.addCallbacks();
};

NanoStateClass.prototype.onRemove = function (nextState) {
  // Do not add code here, add it to the 'default' state (onyxui_defaut.js) or create a new state and override this function

  NanoBaseCallbacks.removeCallbacks();
  NanoBaseHelpers.removeHelpers();
};

NanoStateClass.prototype.onBeforeUpdate = function (data) {
  // Do not add code here, add it to the 'default' state (onyxui_defaut.js) or create a new state and override this function

  data = NanoStateManager.executeBeforeUpdateCallbacks(data);

  return data; // Return data to continue, return false to prevent onUpdate and onAfterUpdate
};

NanoStateClass.prototype.onUpdate = function (data) {
  // Do not add code here, add it to the 'default' state (onyxui_defaut.js) or create a new state and override this function

  windowState = Byond.winget(data.config.windowId, ["is-maximized"]).then(
    function (res) {
      windowState = res;
    }
  );

  try {
    if (
      !this.layoutRendered ||
      (data["config"].hasOwnProperty("autoUpdateLayout") &&
        data["config"]["autoUpdateLayout"])
    ) {
      $("#uiLayout").html(NanoTemplate.parse("layout", data)); // render the 'mail' template to the #mainTemplate div
      this.layoutRendered = true;
    }
    if (
      !this.contentRendered ||
      (data["config"].hasOwnProperty("autoUpdateContent") &&
        data["config"]["autoUpdateContent"])
    ) {
      $("#uiContent").html(NanoTemplate.parse("main", data)); // render the 'mail' template to the #mainTemplate div
      this.contentRendered = true;
    }
    if (NanoTemplate.templateExists("mapContent")) {
      if (!this.mapInitialised) {
        // Add drag functionality to the map ui
        $("#uiMap").draggable();

        $("#uiMapTooltip")
          .off("click")
          .on("click", function (event) {
            event.preventDefault();
            $(this).fadeOut(400);
          });

        this.mapInitialised = true;
      }

      $("#uiMapContent").html(NanoTemplate.parse("mapContent", data)); // render the 'mapContent' template to the #uiMapContent div

      if (
        data["config"].hasOwnProperty("showMap") &&
        data["config"]["showMap"]
      ) {
        $("#uiContent").addClass("hidden");
        $("#uiMapWrapper").removeClass("hidden");
      } else {
        $("#uiMapWrapper").addClass("hidden");
        $("#uiContent").removeClass("hidden");
      }
    }
    if (NanoTemplate.templateExists("mapHeader")) {
      $("#uiMapHeader").html(NanoTemplate.parse("mapHeader", data)); // render the 'mapHeader' template to the #uiMapHeader div
    }
    if (NanoTemplate.templateExists("mapFooter")) {
      $("#uiMapFooter").html(NanoTemplate.parse("mapFooter", data)); // render the 'mapFooter' template to the #uiMapFooter div
    }

    // Setup titlebar buttons event
    $("#closeWindow").on("click", function () {
      Byond.call(null, {
        src: data.config.srcObject.ref,
        close: 1,
      });
    });

    $("#maximizeWindow").on("click", function () {
      var isMaximized = windowState["is-maximized"];

      Byond.winset(data.config.windowId, {
        "is-maximized": !isMaximized,
        pos:
          window.screen.availWidth * 0.4 +
          "x" +
          window.screen.availHeight * 0.4,
      });

      windowState["is-maximized"] = !isMaximized;
    });

    if (data.config.centered) {
      Byond.winset(data.config.windowId, {
        pos:
          window.screen.availWidth * 0.4 +
          "x" +
          window.screen.availHeight * 0.4,
      });
    }

    // Setup correct scrollbars.
    if (data.config.fancy) {
      $("#uiLayout").css({
        "overflow-y": "unset",
      });

      $("#uiContent").css({
        "overflow-y": "auto",
      });

      // Setup drag handling.
      var startDragging = function (event) {
        isDragging = true;
        dragOffset = [
          window.screenLeft - event.screenX,
          window.screenTop - event.screenY,
        ];

        document.addEventListener("mousemove", dragging);
        document.addEventListener("mouseup", endDragging);
      };

      var endDragging = function (event) {
        dragging(event);
        document.removeEventListener("mousemove", dragging);
        document.removeEventListener("mouseup", endDragging);
        isDragging = false;
        dragOffset = [0, 0];
      };

      var dragging = function (event) {
        if (!isDragging) {
          return;
        }

        var targetPosition = [
          event.screenX + dragOffset[0],
          event.screenY + dragOffset[1],
        ];

        event.preventDefault();
        Byond.winset(data.config.windowId, {
          pos: targetPosition[0] + "x" + targetPosition[1],
        });
      };

      document
        .getElementById("uiTitleWrapper")
        .addEventListener("mousedown", startDragging);
    } else {
      $("#uiLayout").css({
        "overflow-y": "auto",
      });

      $("#uiContent").css({
        "overflow-y": "unset",
      });
    }

    // Keep focus on #uiContent for scrolling.
    $("#uiContent").focus();
    window.addEventListener("focusin", function (event) {
      $("#uiContent").focus();
    });
  } catch (error) {
    alert("ERROR: An error occurred while rendering the UI: " + error.message);
    return;
  }
};

NanoStateClass.prototype.onAfterUpdate = function (data) {
  // Do not add code here, add it to the 'default' state (onyxui_defaut.js) or create a new state and override this function

  NanoStateManager.executeAfterUpdateCallbacks(data);
};

NanoStateClass.prototype.alertText = function (text) {
  // Do not add code here, add it to the 'default' state (onyxui_defaut.js) or create a new state and override this function

  alert(text);
};
