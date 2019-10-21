webpackHotUpdate("tgui",{

/***/ "":
false,

/***/ "./interfaces/Jukebox.js":
/*!*******************************!*\
  !*** ./interfaces/Jukebox.js ***!
  \*******************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;
exports.Jukebox = void 0;

var _inferno = __webpack_require__(/*! inferno */ "../../node_modules/inferno/index.esm.js");

var _byond = __webpack_require__(/*! ../byond */ "./byond.js");

var _components = __webpack_require__(/*! ../components */ "./components/index.js");

var Jukebox = function Jukebox(props) {
  var state = props.state;
  var config = state.config,
      data = state.data;
  var ref = config.ref;
  var songs = data.tracks || [];
  return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Control",
    "buttons": (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
      "icon": "minus",
      "onClick": function () {
        function onClick() {
          return (0, _byond.act)(ref, 'volume', {
            level: data.volume - 10
          });
        }

        return onClick;
      }()
    }), (0, _inferno.createComponentVNode)(2, _components.Button, {
      "icon": "plus",
      "onClick": function () {
        function onClick() {
          return (0, _byond.act)(ref, 'volume', {
            level: data.volume + 10
          });
        }

        return onClick;
      }()
    })], 4),
    children: (0, _inferno.createComponentVNode)(2, _components.ProgressBar, {
      "value": String(data.volume / 50),
      "content": 'Volume: ' + data.volume
    })
  }), (0, _inferno.createComponentVNode)(2, _components.Section, {
    "title": "Tracks List",
    children: songs.map(function (song) {
      return (0, _inferno.createFragment)([(0, _inferno.createComponentVNode)(2, _components.Button, {
        "content": song,
        "onClick": function () {
          function onClick() {
            return (0, _byond.act)(ref, 'change_track', {
              title: song
            });
          }

          return onClick;
        }()
      }), (0, _inferno.createVNode)(1, "br")], 4, song);
    })
  })], 4);
};

exports.Jukebox = Jukebox;

/***/ }),

/***/ "./styles/main.scss":
/*!**************************!*\
  !*** ./styles/main.scss ***!
  \**************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

// extracted by extract-css-chunks-webpack-plugin
    if(true) {
      // 1571672731489
      var cssReload = __webpack_require__(/*! C:/Users/Igor/Desktop/OnyxBay/tgui-next/node_modules/extract-css-chunks-webpack-plugin/dist/hmr/hotModuleReplacement.js */ "../../node_modules/extract-css-chunks-webpack-plugin/dist/hmr/hotModuleReplacement.js")(module.i, {"hot":true,"locals":false});
      module.hot.dispose(cssReload);
      module.hot.accept(undefined, cssReload);
    }
  

/***/ })

})