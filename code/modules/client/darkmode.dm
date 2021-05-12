/*
This lets you switch chat themes by using winset and CSS loading, you must relog to see this change (or rebuild your browseroutput datum)

Things to note:
If you change ANYTHING in interface/skin.dmf you need to change it here:
Format:
winset(src, "window as appears in skin.dmf after elem", "var to change = currentvalue;var to change = desired value")

How this works:
I've added a function to browseroutput.js which registers a cookie for darkmode and swaps the chat accordingly. You can find the button to do this under the "cog" icon next to the ping button (top right of chat)
This then swaps the window theme automatically

Thanks to spacemaniac and mcdonald for help with the JS side of this.

*/

/client/proc/force_white_theme() //There's no way round it. We're essentially changing the skin by hand. It's painful but it works, and is the way Lummox suggested.
	set background = TRUE
	winset(src, null ,{"
	infowindow.background-color = none;
	infowindow.text-color = #000000;
	info.background-color = none;
	info.text-color = #000000;
	browseroutput.background-color = none;
	browseroutput.text-color = #000000;
	outputwindow.background-color = none;
	outputwindow.text-color = #000000;
	mainwindow.background-color = none;
	mainvsplit.background-color = none;

	changelog.background-color = none;
	changelog.text-color = #000000;
	rulesb.background-color = none;
	rulesb.text-color = #000000;
	wikib.background-color = none;
	wikib.text-color = #000000;
	discordb.background-color = none;
	discordb.text-color = #000000;
	backstoryb.background-color = none;
	backstoryb.text-color = #000000;
	bugreportb.background-color = none;
	bugreportb.text-color = #000000;
	storeb.background-color = none;
	storeb.text-color = #000000;

	output.background-color = none;
	output.text-color = #000000;
	outputwindow.background-color = none;
	outputwindow.text-color = #000000;
	statwindow.background-color = none;
	statwindow.text-color = #000000;
	stat.background-color = #FFFFFF;
	stat.tab-background-color = none;
	stat.text-color = #000000;
	stat.tab-text-color = #000000;
	stat.prefix-color = #000000;
	stat.suffix-color = #000000;

	hotkey_toggle.background-color = none;
	hotkey_toggle.text-color = #000000;
	saybutton.background-color = none;
	saybutton.text-color = #000000;
	asset_cache_browser.background-color = none;
	asset_cache_browser.background-color = none;
	input.background-color = none;
	input.text-color = #000000;

	hotkey_toggle_alt.background-color = none;
	hotkey_toggle_alt.text-color = #000000;
	saybutton_alt.background-color = none;
	saybutton_alt.text-color = #000000;
	input_alt.background-color = none;
	input_alt.text-color = #000000;
	"})

/client/proc/force_dark_theme() //Inversely, if theyre using the superior white theme and want to swap to dark theme, let's get WINSET() ing
	set background = TRUE
	winset(src, null, {"
	infowindow.background-color = [COLOR_DARKMODE_BACKGROUND];
	infowindow.text-color = [COLOR_DARKMODE_TEXT];
	info.background-color = [COLOR_DARKMODE_BACKGROUND];
	info.text-color = [COLOR_DARKMODE_TEXT];
	browseroutput.background-color = [COLOR_DARKMODE_BACKGROUND];
	browseroutput.text-color = [COLOR_DARKMODE_TEXT];
	outputwindow.background-color = [COLOR_DARKMODE_BACKGROUND];
	outputwindow.text-color = [COLOR_DARKMODE_TEXT];
	mainwindow.background-color = [COLOR_DARKMODE_BACKGROUND];
	mainvsplit.background-color = [COLOR_DARKMODE_BACKGROUND];

	changelog.background-color = #494949;
	changelog.text-color = [COLOR_DARKMODE_TEXT];
	rulesb.background-color = #494949;
	rulesb.text-color = [COLOR_DARKMODE_TEXT];
	wikib.background-color = #494949;
	wikib.text-color = [COLOR_DARKMODE_TEXT];
	discordb.background-color = #494949;
	discordb.text-color = [COLOR_DARKMODE_TEXT];
	backstoryb.background-color = #494949;
	backstoryb.text-color = [COLOR_DARKMODE_TEXT];
	bugreportb.background-color = #494949;
	bugreportb.text-color = [COLOR_DARKMODE_TEXT];
	storeb.background-color = #494949;
	storeb.text-color = [COLOR_DARKMODE_TEXT];

	output.background-color = [COLOR_DARKMODE_DARKBACKGROUND];
	output.text-color = [COLOR_DARKMODE_TEXT];
	outputwindow.background-color = [COLOR_DARKMODE_DARKBACKGROUND];
	outputwindow.text-color = [COLOR_DARKMODE_TEXT];
	statwindow.background-color = [COLOR_DARKMODE_DARKBACKGROUND];
	statwindow.text-color = [COLOR_DARKMODE_TEXT];
	stat.background-color = [COLOR_DARKMODE_DARKBACKGROUND];
	stat.tab-background-color = [COLOR_DARKMODE_BACKGROUND];
	stat.text-color = [COLOR_DARKMODE_TEXT];
	stat.tab-text-color = [COLOR_DARKMODE_TEXT];
	stat.prefix-color = [COLOR_DARKMODE_TEXT];
	stat.suffix-color = [COLOR_DARKMODE_TEXT];

	saybutton.background-color = #494949;
	saybutton.text-color = [COLOR_DARKMODE_TEXT];
	asset_cache_browser.background-color = [COLOR_DARKMODE_BACKGROUND];
	asset_cache_browser.text-color = [COLOR_DARKMODE_TEXT];
	hotkey_toggle.background-color = #494949;
	hotkey_toggle.text-color = [COLOR_DARKMODE_TEXT];
	input.background-color = [COLOR_DARKMODE_BACKGROUND];
	input.text-color = [COLOR_DARKMODE_TEXT];

	saybutton_alt.background-color = #494949;
	saybutton_alt.text-color = [COLOR_DARKMODE_TEXT];
	hotkey_toggle_alt.background-color = #494949;
	hotkey_toggle_alt.text-color = [COLOR_DARKMODE_TEXT];
	input_alt.background-color = [COLOR_DARKMODE_BACKGROUND];
	input_alt.text-color = [COLOR_DARKMODE_TEXT];
	"})

/client/proc/force_marines_mode()
	set background = TRUE
	winset(src, null, {"
	infowindow.background-color = [COLOR_MARINEMODE_BACKGROUND];
	infowindow.text-color = [COLOR_MARINEMODE_TEXT];
	info.background-color = [COLOR_MARINEMODE_BACKGROUND];
	info.text-color = [COLOR_MARINEMODE_TEXT];
	browseroutput.background-color = [COLOR_MARINEMODE_BACKGROUND];
	browseroutput.text-color = [COLOR_MARINEMODE_TEXT];
	outputwindow.background-color = [COLOR_MARINEMODE_BACKGROUND];
	outputwindow.text-color = [COLOR_MARINEMODE_TEXT];
	mainwindow.background-color = [COLOR_MARINEMODE_BACKGROUND];
	mainvsplit.background-color = [COLOR_MARINEMODE_BACKGROUND];

	changelog.background-color = [COLOR_MARINEMODE_GRAYBUTTON];
	changelog.text-color = [COLOR_MARINEMODE_TEXT];
	rulesb.background-color = [COLOR_MARINEMODE_GRAYBUTTON];
	rulesb.text-color = [COLOR_MARINEMODE_TEXT];
	wikib.background-color = [COLOR_MARINEMODE_GRAYBUTTON];
	wikib.text-color = [COLOR_MARINEMODE_TEXT];
	discordb.background-color = [COLOR_MARINEMODE_GRAYBUTTON];
	discordb.text-color = [COLOR_MARINEMODE_TEXT];
	backstoryb.background-color = [COLOR_MARINEMODE_GRAYBUTTON];
	backstoryb.text-color = [COLOR_MARINEMODE_TEXT];
	bugreportb.background-color = [COLOR_MARINEMODE_GRAYBUTTON];
	bugreportb.text-color = [COLOR_MARINEMODE_TEXT];
	storeb.background-color = [COLOR_MARINEMODE_GRAYBUTTON];
	storeb.text-color = [COLOR_MARINEMODE_TEXT];

	output.background-color = [COLOR_MARINEMODE_BACKGROUND];
	output.text-color = [COLOR_MARINEMODE_TEXT];
	outputwindow.background-color = [COLOR_MARINEMODE_BACKGROUND];
	outputwindow.text-color = [COLOR_MARINEMODE_TEXT];
	statwindow.background-color = [COLOR_MARINEMODE_BACKGROUND];
	statwindow.text-color = [COLOR_MARINEMODE_TEXT];
	stat.background-color = [COLOR_MARINEMODE_BACKGROUND];
	stat.tab-background-color = [COLOR_MARINEMODE_BACKGROUND];
	stat.text-color = [COLOR_MARINEMODE_TEXT];
	stat.tab-text-color = [COLOR_MARINEMODE_TEXT];
	stat.prefix-color = [COLOR_MARINEMODE_TEXT];
	stat.suffix-color = [COLOR_MARINEMODE_TEXT];

	saybutton.background-color = [COLOR_MARINEMODE_GRAYBUTTON];
	saybutton.text-color = [COLOR_MARINEMODE_TEXT];
	asset_cache_browser.background-color = [COLOR_MARINEMODE_GRAYBUTTON];
	asset_cache_browser.text-color = [COLOR_MARINEMODE_TEXT];
	hotkey_toggle.background-color = [COLOR_MARINEMODE_GRAYBUTTON];
	hotkey_toggle.text-color = [COLOR_MARINEMODE_TEXT];
	input.background-color = [COLOR_MARINEMODE_BACKGROUND];
	input.text-color = [COLOR_MARINEMODE_TEXT];

	saybutton_alt.background-color = [COLOR_MARINEMODE_GRAYBUTTON];
	saybutton_alt.text-color = [COLOR_MARINEMODE_TEXT];
	hotkey_toggle_alt.background-color = [COLOR_MARINEMODE_GRAYBUTTON];
	hotkey_toggle_alt.text-color = [COLOR_MARINEMODE_TEXT];
	input_alt.background-color = [COLOR_MARINEMODE_BACKGROUND];
	input_alt.text-color = [COLOR_MARINEMODE_TEXT];
	"})
