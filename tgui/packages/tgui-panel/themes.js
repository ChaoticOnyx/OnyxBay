/* eslint-disable no-undef */
/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const THEMES = ["light", "dark"];

const COLOR_DARK_BG = "#202020";
const COLOR_DARK_BG_DARKER = "#171717";
const COLOR_DARK_TEXT = "#a4bad6";

let setClientThemeTimer = null;

/**
 * Darkmode preference, originally by Kmc2000.
 *
 * This lets you switch client themes by using winset.
 *
 * If you change ANYTHING in interface/skin.dmf you need to change it here.
 *
 * There's no way round it. We're essentially changing the skin by hand.
 * It's painful but it works, and is the way Lummox suggested.
 */
export const setClientTheme = (name) => {
  // Transmit once for fast updates and again in a little while in case we won
  // the race against statbrowser init.
  clearInterval(setClientThemeTimer);
  Byond.command(`.output statbrowser:set_theme ${name}`);
  setClientThemeTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_theme ${name}`);
  }, 1500);

  if (name === "light") {
    return Byond.winset({
      // Main windows
      "infowindow.background-color": "none",
      "infowindow.text-color": "#000000",
      "info.background-color": "none",
      "info.text-color": "#000000",
      "browseroutput.background-color": "none",
      "browseroutput.text-color": "#000000",
      "outputwindow.background-color": "none",
      "outputwindow.text-color": "#000000",
      "mainwindow.background-color": "none",
      "mainvsplit.background-color": "none",
      "statusbar.background-color": "none",
      "statusbar.text-color": "#000000",
      // Buttons
      "changelog.background-color": "none",
      "changelog.text-color": "#000000",
      "rulesb.background-color": "none",
      "rulesb.text-color": "#000000",
      "wikib.background-color": "none",
      "wikib.text-color": "#000000",
      "discordb.background-color": "none",
      "discordb.text-color": "#000000",
      "backstoryb.background-color": "none",
      "backstoryb.text-color": "#000000",
      "bugreportb.background-color": "none",
      "bugreportb.text-color": "#000000",
      "storeb.background-color": "none",
      "storeb.text-color": "#000000",
      // Status and verb tabs
      "output.background-color": "none",
      "output.text-color": "#000000",
      "statwindow.background-color": "none",
      "statwindow.text-color": "#000000",
	  "stat.background-color": "#FFFFFF",
	  "stat.tab-background-color": "none",
	  "stat.text-color": "#000000",
	  "stat.tab-text-color": "#000000",
	  "stat.prefix-color": "#000000",
	  "stat.suffix-color": "#000000",
      "asset_cache_browser.background-color": "none",
      "asset_cache_browser.text-color": "#000000",
      // Say, OOC, me Buttons etc.
      "saybutton.background-color": "none",
      "saybutton.text-color": "#000000",
      "hotkey_toggle.background-color": "none",
      "hotkey_toggle.text-color": "#000000",
      "input.background-color": "none",
      "input.text-color": "#000000",
      // Alt variants
      "saybutton_alt.background-color": "none",
      "saybutton_alt.text-color": "#000000",
      "hotkey_toggle_alt.background-color": "none",
      "hotkey_toggle_alt.text-color": "#000000",
      "input_alt.background-color": "none",
      "input_alt.text-color": "#000000",
    });
  }
  if (name === "dark") {
    Byond.winset({
      // Main windows
      "infowindow.background-color": COLOR_DARK_BG,
      "infowindow.text-color": COLOR_DARK_TEXT,
      "info.background-color": COLOR_DARK_BG,
      "info.text-color": COLOR_DARK_TEXT,
      "browseroutput.background-color": COLOR_DARK_BG,
      "browseroutput.text-color": COLOR_DARK_TEXT,
      "outputwindow.background-color": COLOR_DARK_BG,
      "outputwindow.text-color": COLOR_DARK_TEXT,
      "mainwindow.background-color": COLOR_DARK_BG,
      "mainvsplit.background-color": COLOR_DARK_BG,
      "statusbar.background-color": COLOR_DARK_BG,
      "statusbar.text-color": COLOR_DARK_TEXT,
      // Buttons
      "changelog.background-color": "#494949",
      "changelog.text-color": COLOR_DARK_TEXT,
      "rulesb.background-color": "#494949",
      "rulesb.text-color": COLOR_DARK_TEXT,
      "wikib.background-color": "#494949",
      "wikib.text-color": COLOR_DARK_TEXT,
      "discordb.background-color": "#494949",
      "discordb.text-color": COLOR_DARK_TEXT,
      "backstoryb.background-color": "#494949",
      "backstoryb.text-color": COLOR_DARK_TEXT,
      "bugreportb.background-color": "#494949",
      "bugreportb.text-color": COLOR_DARK_TEXT,
      "storeb.background-color": "#494949",
      "storeb.text-color": COLOR_DARK_TEXT,
      // Status and verb tabs
      "output.background-color": COLOR_DARK_BG_DARKER,
      "output.text-color": COLOR_DARK_TEXT,
      "statwindow.background-color": COLOR_DARK_BG_DARKER,
      "statwindow.text-color": COLOR_DARK_TEXT,
	  "stat.background-color": COLOR_DARK_BG_DARKER,
	  "stat.tab-background-color": COLOR_DARK_BG,
	  "stat.text-color": COLOR_DARK_TEXT,
	  "stat.tab-text-color": COLOR_DARK_TEXT,
	  "stat.prefix-color": COLOR_DARK_TEXT,
	  "stat.suffix-color": COLOR_DARK_TEXT,
      "asset_cache_browser.background-color": COLOR_DARK_BG,
      "asset_cache_browser.text-color": COLOR_DARK_TEXT,
      // Say, OOC, me Buttons etc.
      "saybutton.background-color": COLOR_DARK_BG,
      "saybutton.text-color": COLOR_DARK_TEXT,
      "hotkey_toggle.background-color": COLOR_DARK_BG,
      "hotkey_toggle.text-color": COLOR_DARK_TEXT,
      "input.background-color": COLOR_DARK_BG,
      "input.text-color": COLOR_DARK_TEXT,
      // Alt vartiants
      "saybutton_alt.background-color": COLOR_DARK_BG,
      "saybutton_alt.text-color": COLOR_DARK_TEXT,
      "hotkey_toggle_alt.background-color": COLOR_DARK_BG,
      "hotkey_toggle_alt.text-color": COLOR_DARK_TEXT,
      "input_alt.background-color": COLOR_DARK_BG,
      "input_alt.text-color": COLOR_DARK_TEXT,
    });
  }
};
