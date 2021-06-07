Sqrl.helpers.define("link", function (content, blocks, _) {
  var args = content.params[0] || {};
  var parameters = args.act;
  var body = args.body;
  var classes = args.class || "";
  var enabled = args.enabled;
  var selected = args.selected || false;
  var dataHref = "";
  var attribute = "";

  if (parameters) {
    dataHref = 'data-href="' + NanoUtility.generateHref(parameters);
  }

  if (Array.isArray(classes)) {
    classes = classes.join(" ");
  }

  if (enabled !== false) {
    enabled = true;
  }

  if (enabled) {
    if (selected) {
      attribute = "selected";
    } else {
      attribute = "enabled";
    }
  }

  for (var i = 0; i < blocks.length; i++) {
    var block = blocks[i];

    switch (block.name) {
      case "body":
        body = block.exec();
        break;
      case "class":
        classes = block.exec();
        break;
    }
  }

  return (
    "<div " +
    attribute +
    ' class="button ' +
    classes +
    '" ' +
    dataHref +
    '">' +
    body +
    "</div>"
  );
});

Sqrl.helpers.define("icon", function (content, blocks, _) {
  var args = content.params[0] || {};
  iconName = args.name;
  iconType = args.type || "s";

  return '<span class="fa' + iconType + " fa-" + iconName + '"></span>';
});

Sqrl.helpers.define("progressBar", function (content, _, __) {
  var args = content.params[0] || {};
  var value = args.value;
  var min = args.min;
  var max = args.max;
  var classes = args.class || "";
  var showText = args.text || "";

  if (Array.isArray(classes)) {
    classes = classes.join(" ");
  }

  if (min < max) {
    if (value < min) {
      value = min;
    } else if (value > max) {
      value = max;
    }
  } else {
    if (value > min) {
      value = min;
    } else if (value < max) {
      value = max;
    }
  }

  var percentage = Math.round(((value - min) / (max - min)) * 100);

  return (
    '<div class="displayBar ' +
    classes +
    '"><div class="displayBar' +
    "Fill " +
    classes +
    '" style="width: ' +
    percentage +
    '%;"></div><div class="displayBar' +
    "Text " +
    classes +
    '">' +
    showText +
    "</div></div>"
  );
});

Sqrl.helpers.define("css", function (content, _, __) {
  var args = content.params[0];
  var fileName = args.fileName;

  $("head").append(
    '<link rel="stylesheet" href="' + fileName + '" type="text/css" />'
  );

  return "";
});

Sqrl.helpers.define("theme", function (content, _, __) {
  var args = content.params[0];
  var name = args.config.templateName;
  var theme = args.config.theme;
  var fileName = name + "." + theme + ".theme.css";

  Sqrl.helpers.cache.css({ params: [{ fileName: fileName }] }, _, __);

  return "";
});

Sqrl.helpers.define("window", function (content, _, __) {
  var args = content.params[0];
  var config = content.params[1].config;
  var width = args.width;
  var height = args.height;

  Byond.winset(config.windowId, {
    size: width + "x" + height,
  });

  return "";
});
