/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) "<span class='maptext'>[##text]</span>"
/// Macro from Lummox used to get height from a MeasureText proc
#define WXH_TO_HEIGHT(measurement) text2num(copytext(##measurement, findtextEx(##measurement, "x") + 1))
