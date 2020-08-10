/*
This file exists only because BYOND does not support css/class in maptext, as for v.513.1528
If you ever need to implement your css in any other situation, consider a bunch of '*.css' files in this build and '/code/modules/client/asset_cache.dm', instead
*/
/datum/css_style
	var/font_size = 9
	var/color = "white"
	var/outline_color = "black"
	var/alignment = "center"
	var/font_family
	var/shadow_color
	var/max_char_width = 9 // Depends on BYOND representation of used font

/datum/css_style/proc/get_string()
	. = "vertical-align: bottom;"
	if(font_size)
		. += "font-size: [font_size]px;"
	if(color)
		. += " color: [color];"
	if(outline_color)
		. += " -dm-text-outline: 1 [outline_color];"
	if(alignment)
		. += " text-align: [alignment];"
	if(font_family)
		. += " font-family: [font_family];"
	if(shadow_color)
		. += " text-shadow: 0 0 5px [shadow_color];"
	return .

/datum/css_style/proc/decorate(var/text)
	return "<span style='[get_string()]'>[text]</span>"

/datum/css_style/human
	font_size = 9
	color = "#A6A6A6"
	outline_color = "black"
	max_char_width = 9

/datum/css_style/human/male
	color = "#A6A6DD"

/datum/css_style/human/female
	color = "#DBA6DB" // Trap detector goes 'pink-pink'

/datum/css_style/robot
	font_size = 9
	color = "#A6A6A6"
	outline_color = "black"
	font_family = "Consolas, monospace"
	max_char_width = 7

/datum/css_style/alien
	font_size = 12
	color = "#33CC33"
	outline_color = "#707000"
	font_family = "cursive"
	max_char_width = 12

/datum/css_style/deity
	font_size = 12
	color = "#FFD700"
	outline_color = "#009966"
	font_family = "cursive"
	shadow_color = "#FFFF88"
	max_char_width = 12

/datum/css_style/donator
	font_size = 9
	color = "#707070"
	outline_color = "#FFD700"
	shadow_color = "#FFFF88"
	max_char_width = 9

/datum/css_style/donator/male
	color = "#7070D8"

/datum/css_style/donator/female
	color = "#D870D8"

/datum/css_style/animal
	font_size = 9
	color = "#A6A6A6"
	outline_color = "#404040"
	max_char_width = 9

/datum/css_style/animal/friendly
	color = "#80A080"

/datum/css_style/animal/hostile
	color = "#CC5151"
