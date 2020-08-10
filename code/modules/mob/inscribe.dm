/*
Call inscribe() to create a floating comment above a mob.
Used for 'hover' tips.
*/
#define MAPTEXT_MAX_WIDTH 160

/mob/proc/inscribe(...) // Any amount of text arguments is acceptable
	if(!maptext_style)
		return
	
	var/list/strings = list()
	for(var/string in args)
		if(!istext(string))
			string = "[string]"
		strings += splittext_char(string, "\n")
	
	if(!length(strings))
		maptext = ""
		return
	
	var/text = ""
	maptext_width = 0
	maptext_height = 100 * length(strings)
	for(var/i = 1, i <= length(strings), i++)
		var/length = length_char(strings[i])
		if(length * maptext_style.max_char_width > MAPTEXT_MAX_WIDTH)
			strings[i] = copytext(strings[i], 1, round(MAPTEXT_MAX_WIDTH / maptext_style.max_char_width)) + ".."
			length = length_char(strings[i])
		if(maptext_width < length * maptext_style.max_char_width)
			maptext_width = length * maptext_style.max_char_width
		text += strings[i]
		if(i != length(strings))
			text += "\n"
	
	maptext_x = (bound_width - maptext_width) / 2
	maptext_style.alignment = "center"
	if(usr && usr.client)
		var/pixels_from_right = (x - 0.5) * world.icon_size - usr.client.bound_x
		if(pixels_from_right < maptext_width / 2)
			maptext_x = usr.client.bound_x - (x - 1) * world.icon_size
			maptext_style.alignment = "left"
		else if(pixels_from_right > (usr.client.bound_width - maptext_width / 2))
			maptext_x = usr.client.bound_x + usr.client.bound_width - (x - 1) * world.icon_size - maptext_width - 2
			maptext_style.alignment = "right"
	
	maptext_y = bound_height
	
	maptext = maptext_style.decorate(text)

/****************
*  MOUSE HOVER  *
****************/

#define INSCRIBE_DELAY 4 // Minimum interval for hover tip to show (*10 ms). Helps to make thing more readable and avoid flickering.

var/mob/last_mob_hovered
var/next_hover_allowed = 0 // World.time before hover can be resolved. Reduces cpu time.
/mob
	var/is_hovered = FALSE

/mob/proc/show_hover_tip()
	inscribe(name)

mob/MouseEntered()
	is_hovered = TRUE
	if(!maptext_style || !usr || usr.get_preference_value(/datum/client_preference/hover_tips) == GLOB.PREF_NO)
		return // Return early, since we don't use MouseEntered() for anything else but showing hover tips using maptext
	
	if(src == last_mob_hovered)
		if(world.time < next_hover_allowed)
			return
	else
		if(last_mob_hovered)
			last_mob_hovered.inscribe() // Only one sign at a time, flush previous one
		last_mob_hovered = src
	next_hover_allowed = world.time + INSCRIBE_DELAY
	layer += 0.01 // Bump over adjacent mobs on the same layer
	show_hover_tip()
	layer -= 0.01

mob/MouseExited()
	is_hovered = FALSE
	if(!maptext_style || !usr || usr.get_preference_value(/datum/client_preference/hover_tips) == GLOB.PREF_NO)
		return
	
	spawn(INSCRIBE_DELAY)
		if(!is_hovered && length(maptext))
			inscribe()
