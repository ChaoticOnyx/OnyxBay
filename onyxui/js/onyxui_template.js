var NanoTemplate = (function () {
  var _templateData = {};

  var _templates = {};

  var init = function () {
    // We store templateData in the body tag, it's as good a place as any
    _templateData = $("body").data("templateData");

    if (_templateData == null) {
      alert("Error: Template data did not load correctly.");
    }

    loadNextTemplate();
  };

  var loadNextTemplate = function () {
    // we count the number of templates for this ui so that we know when they've all been rendered
    var templateCount = Object.size(_templateData);

    if (!templateCount) {
      $(document).trigger("templatesLoaded");
      return;
    }

    // load markup for each template and register it
    for (var key in _templateData) {
      if (!_templateData.hasOwnProperty(key)) {
        continue;
      }

      $.when(
        $.ajax({
          url: _templateData[key],
          cache: false,
          dataType: "text",
        })
      )
        .done(function (templateMarkup) {
          templateMarkup += '<div class="clearBoth"></div>';

          try {
            NanoTemplate.addTemplate(key, templateMarkup);
          } catch (error) {
            alert(
              "ERROR: An error occurred while loading the UI: " + error.message
            );
            return;
          }

          delete _templateData[key];

          loadNextTemplate();
        })
        .fail(function () {
          alert(
            "ERROR: Loading template " +
              key +
              "(" +
              _templateData[key] +
              ") failed!"
          );
        });

      return;
    }
  };

  return {
    init: function () {
      init();
    },
    addTemplate: function (key, templateString) {
      _templates[key] = templateString;
    },
    templateExists: function (key) {
      return _templates.hasOwnProperty(key);
    },
    parse: function (templateKey, data) {
      return Sqrl.render(_templates[templateKey], data, Sqrl.defaultConfig);
    },
  };
})();
