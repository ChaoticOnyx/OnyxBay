// Thanks https://github.com/tgstation/tgstation/blob/c90c2e5141922724a0e1ceb89437e4497238e564/tgui/public/tgui.html

// Utility functions
var hasOwn = Object.prototype.hasOwnProperty;
var assign = function (target) {
  for (var i = 1; i < arguments.length; i++) {
    var source = arguments[i];
    for (var key in source) {
      if (hasOwn.call(source, key)) {
        target[key] = source[key];
      }
    }
  }
  return target;
};

// BYOND API object
// ------------------------------------------------------

var Byond = (window.Byond = {});
// Trident engine version
var tridentVersion = (function () {
  var groups = navigator.userAgent.match(/Trident\/(\d+).+?;/i);
  var majorVersion = groups && groups[1];
  return majorVersion ? parseInt(majorVersion, 10) : null;
})();

// Basic checks to detect whether this page runs in BYOND
var isByond =
  (tridentVersion !== null || window.cef_to_byond) &&
  location.hostname === "127.0.0.1" &&
  location.pathname.indexOf("/tmp") === 0 &&
  location.search !== "?external";

// Version constants
Byond.IS_BYOND = isByond;
Byond.IS_LTE_IE8 = tridentVersion !== null && tridentVersion <= 4;
Byond.IS_LTE_IE9 = tridentVersion !== null && tridentVersion <= 5;
Byond.IS_LTE_IE10 = tridentVersion !== null && tridentVersion <= 6;
Byond.IS_LTE_IE11 = tridentVersion !== null && tridentVersion <= 7;

// Callbacks for asynchronous calls
Byond.__callbacks__ = [];

// Reviver for BYOND JSON
// IE8: No reviver for you!
// See: https://stackoverflow.com/questions/1288962
var byondJsonReviver;
if (!Byond.IS_LTE_IE8) {
  byondJsonReviver = function (key, value) {
    if (typeof value === "object" && value !== null && value.__number__) {
      return parseFloat(value.__number__);
    }
    return value;
  };
}

// Makes a BYOND call.
// See: https://secure.byond.com/docs/ref/skinparams.html
Byond.call = function (path, params) {
  // Not running in BYOND, abort.
  if (!isByond) {
    return;
  }
  // Build the URL
  var url = (path || "") + "?";
  var i = 0;
  if (params) {
    for (var key in params) {
      if (hasOwn.call(params, key)) {
        if (i++ > 0) {
          url += "&";
        }
        var value = params[key];
        if (value === null || value === undefined) {
          value = "";
        }
        url += encodeURIComponent(key) + "=" + encodeURIComponent(value);
      }
    }
  }

  // If we're a Chromium client, just use the fancy method
  if (window.cef_to_byond) {
    cef_to_byond("byond://" + url);
    return;
  }

  // Perform a standard call via location.href
  if (url.length < 2048) {
    location.href = "byond://" + url;
    return;
  }
  // Send an HTTP request to DreamSeeker's HTTP server.
  // Allows sending much bigger payloads.
  var xhr = new XMLHttpRequest();
  xhr.open("GET", url);
  xhr.send();
};

Byond.callAsync = function (path, params) {
  if (!window.Promise) {
    throw new Error("Async calls require API level of ES2015 or later.");
  }
  var index = Byond.__callbacks__.length;
  var promise = new window.Promise(function (resolve) {
    Byond.__callbacks__.push(resolve);
  });
  Byond.call(
    path,
    assign({}, params, {
      callback: "Byond.__callbacks__[" + index + "]",
    })
  );
  return promise;
};

Byond.topic = function (params) {
  return Byond.call("", params);
};

Byond.command = function (command) {
  return Byond.call("winset", {
    command: command,
  });
};

Byond.winget = function (id, propName) {
  var isArray = propName instanceof Array;
  var isSpecific = propName && propName !== "*" && !isArray;
  var promise = Byond.callAsync("winget", {
    id: id,
    property: (isArray && propName.join(",")) || propName || "*",
  });
  if (isSpecific) {
    promise = promise.then(function (props) {
      return props[propName];
    });
  }
  return promise;
};

Byond.winset = function (id, propName, propValue) {
  if (typeof id === "object" && id !== null) {
    return Byond.call("winset", id);
  }
  var props = {};
  if (typeof propName === "string") {
    props[propName] = propValue;
  } else {
    assign(props, propName);
  }
  props.id = id;
  return Byond.call("winset", props);
};

Byond.parseJson = function (json) {
  try {
    return JSON.parse(json, byondJsonReviver);
  } catch (err) {
    throw new Error("JSON parsing error: " + (err && err.message));
  }
};
