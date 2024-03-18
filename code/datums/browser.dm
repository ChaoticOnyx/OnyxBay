/datum/browser
	var/mob/user
	var/title
	var/window_id // window_id is used as the window name for browse and onclose
	var/width = 0
	var/height = 0
	var/weakref/ref = null
	var/window_options = "focus=0;can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;" // window option is set using window_id
	var/stylesheets[0]
	var/scripts[0]
	var/title_image
	var/head_elements
	var/body_elements
	var/head_content = ""
	var/content = ""
	var/title_buttons = ""


/datum/browser/New(nuser, nwindow_id, ntitle = 0, nwidth = 0, nheight = 0, atom/nref = null)
	user = nuser
	register_signal(user, SIGNAL_QDELETING, nameof(.proc/user_deleted))
	window_id = nwindow_id
	if(ntitle)
		title = format_text(ntitle)
	if(nwidth)
		width = nwidth
	if(nheight)
		height = nheight
	if(nref)
		ref = weakref(nref)
	// If a client exists, but they have disabled fancy windowing, disable it!
	if(user?.client?.get_preference_value(/datum/client_preference/browser_style) == GLOB.PREF_PLAIN)
		return
	add_stylesheet("common", 'html/browser/common.css') // this CSS sheet is common to all UIs

/datum/browser/proc/user_deleted(datum/source)
	unregister_signal(user, SIGNAL_QDELETING)
	user = null

/datum/browser/proc/process_icons(text)
	//taken from to_chat(), processes all explanded \icon macros since they don't work in minibrowser (they only work in text output)
	var/static/regex/icon_replacer = new(@/<IMG CLASS=icon SRC=(\[[^]]+])(?: ICONSTATE='([^']+)')?>/, "g")	//syntax highlighter fix -> '
	while(icon_replacer.Find(text))
		text =\
			copytext(text,1,icon_replacer.index) +\
			icon2html(locate(icon_replacer.group[1]), target = user, icon_state=icon_replacer.group[2]) +\
			copytext(text,icon_replacer.next)
	return text

/datum/browser/proc/set_title(ntitle)
	title = format_text(ntitle)

/datum/browser/proc/add_head_content(nhead_content)
	head_content += process_icons(nhead_content)

/datum/browser/proc/set_title_buttons(ntitle_buttons)
	title_buttons = ntitle_buttons

/datum/browser/proc/set_window_options(nwindow_options)
	window_options = nwindow_options

/datum/browser/proc/set_title_image(ntitle_image)
	//title_image = ntitle_image

/datum/browser/proc/add_stylesheet(name, file)
	stylesheets[name] = file

/datum/browser/proc/add_script(name, file)
	scripts[name] = file

/datum/browser/proc/set_content(ncontent)
	content = process_icons(ncontent)

/datum/browser/proc/add_content(ncontent)
	content += process_icons(ncontent)

/datum/browser/proc/get_header()
	var/key
	var/filename
	for (key in stylesheets)
		filename = "[ckey(key)].css"
		send_rsc(user, stylesheets[key], filename)
		head_content += "<link rel='stylesheet' type='text/css' href='[filename]'>"

	for (key in scripts)
		filename = "[ckey(key)].js"
		send_rsc(user, scripts[key], filename)
		head_content += "<script type='text/javascript' src='[filename]'></script>"

	var/title_attributes = "class='uiTitle'"
	if (title_image)
		title_attributes = "class='uiTitle icon' style='background-image: url([title_image]);'"

	return {"<!DOCTYPE html>
<html>
	<meta charset=\"utf-8\">
	<head>
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		[head_content]
	</head>
	<body scroll=auto>
		<div class='uiWrapper'>
			[title ? "<div class='uiTitleWrapper'><div [title_attributes]><tt>[title]</tt></div><div class='uiTitleButtons'>[title_buttons]</div></div>" : ""]
			<div class='uiContent'>
	"}

/datum/browser/proc/get_footer()
	return {"
			</div>
		</div>
	</body>
</html>"}

/datum/browser/proc/get_content()
	return {"
	[get_header()]
	[content]
	[get_footer()]
	"}

/datum/browser/proc/open(use_onclose = 1)
	var/window_size = ""
	if(width && height)
		window_size = "size=[width]x[height];"
	show_browser(user, get_content(), "window=[window_id];[window_size][window_options]")
	winset(user, "mapwindow.map", "focus=true")
	if(use_onclose)
		setup_onclose()

/datum/browser/proc/update(force_open = 0, use_onclose = 1)
	if(force_open)
		open(use_onclose)
	else
		send_output(user, get_content(), "[window_id].browser")

/datum/browser/proc/setup_onclose()
	set waitfor = 0 // winexists sleeps, so we don't need to.
	for(var/i in 1 to 10)
		if(user?.client && winexists(user, window_id))
			var/atom/send_ref
			if(ref)
				send_ref = ref.resolve()
				if(!send_ref)
					ref = null
			onclose(user, window_id, send_ref)
			break

/datum/browser/proc/close()
	close_browser(user, "window=[window_id]")

/datum/browser/Destroy()
	ref = null
	user = null

	. = ..()

// This will allow you to show an icon in the browse window
// This is added to mob so that it can be used without a reference to the browser object
// There is probably a better place for this...
/mob/proc/browse_rsc_icon(icon, icon_state, dir = -1)
	/*
	var/icon/I
	if (dir >= 0)
		I = new /icon(icon, icon_state, dir)
	else
		I = new /icon(icon, icon_state)
		dir = "default"

	var/filename = "[ckey("[icon]_[icon_state]_[dir]")].png"
	send_rsc(src, I, filename)
	return filename
	*/


// Registers the on-close verb for a browse window (client/verb/.windowclose)
// this will be called when the close-button of a window is pressed.
//
// This is usually only needed for devices that regularly update the browse window,
// e.g. canisters, timers, etc.
//
// windowid should be the specified window name
// e.g. code is	: show_browser(user, text, "window=fred")
// then use 	: onclose(user, "fred")
//
// Optionally, specify the "ref" parameter as the controlled atom (usually src)
// to pass a "close=1" parameter to the atom's Topic() proc for special handling.
// Otherwise, the user mob's machine var will be reset directly.
//
/proc/onclose(mob/user, windowid, atom/ref=null)
	if(!user || !user.client)
		return
	var/param = "null"
	if(ref)
		param = "\ref[ref]"

	winset(user, windowid, "on-close=\".windowclose [param]\"")

//	log_debug("OnClose [user]: [windowid] : ["on-close=\".windowclose [param]\""]")



// the on-close client verb
// called when a browser popup window is closed after registering with proc/onclose()
// if a valid atom reference is supplied, call the atom's Topic() with "close=1"
// otherwise, just reset the client mob's machine var.
//
/client/verb/windowclose(atomref as text)
	set hidden = 1						// hide this verb from the user's panel
	set name = ".windowclose"			// no autocomplete on cmd line

//	log_debug("windowclose: [atomref]")

	if(atomref!="null")				// if passed a real atomref
		var/hsrc = locate(atomref)	// find the reffed atom
		if(hsrc)
//			log_debug("[src] Topic [href] [hsrc]")

			usr = src.mob
			src.Topic("close=1", list("close"="1"), hsrc)	// this will direct to the atom's
			return										// Topic() proc via client.Topic()

	// no atomref specified (or not found)
	// so just reset the user mob's machine var
	if(src?.mob)
		src.mob.unset_machine()
	return

/proc/listpicker(mob/User,Message, Title, Button1="Ok", Button2, Button3, list/values, inputtype = "checkbox", width, height, slidecolor)
	if(!istype(User))
		if(istype(User, /client/))
			var/client/C = User
			User = C.mob
		else
			return

	var/datum/browser/listpicker/A = new(User, Message, Title, Button1, Button2, Button3, values, inputtype, width, height, slidecolor)
	A.open()
	A.wait()

	if(A.selectedbutton)
		return list("button" = A.selectedbutton, "values" = A.valueslist)

/datum/browser/listpicker
	var/valueslist = list()
	var/opentime = 0
	var/selectedbutton = 0

/datum/browser/listpicker/New(User,Message,Title,Button1="Ok",Button2,Button3,list/values,inputtype="checkbox", width, height, slidecolor)
	if (!User)
		return

	var/output = {"<form><input type="hidden" name="src" value="[ref(src)]"><ul class="sparse">"}
	if (inputtype == "checkbox" || inputtype == "radio")
		for (var/i in values)
			var/div_slider = slidecolor
			if(!i["allowed_edit"])
				div_slider = "locked"
			output += {"<li>
						<label class="switch">
							<input type="[inputtype]" value="1" name="[i["name"]]"[i["checked"] ? " checked" : ""][i["allowed_edit"] ? "" : " onclick='return false' onkeydown='return false'"]>
								<div class="slider [div_slider ? "[div_slider]" : ""]"></div>
									<span>[i["name"]]</span>
						</label>
						</li>"}
	else
		for (var/i in values)
			output += {"<li><input id="name="[i["name"]]"" style="width: 50px" type="[type]" name="[i["name"]]" value="[i["value"]]">
			<label for="[i["name"]]">[i["name"]]</label></li>"}
	output += {"</ul><div style="text-align:center">
		<button type="submit" name="button" value="1" style="font-size:large;float:[( Button2 ? "left" : "right" )]">[Button1]</button>"}

	if (Button2)
		output += {"<button type="submit" name="button" value="2" style="font-size:large;[( Button3 ? "" : "float:right" )]">[Button2]</button>"}

	if (Button3)
		output += {"<button type="submit" name="button" value="3" style="font-size:large;float:right">[Button3]</button>"}

	output += {"</form></div>"}
	..(User, ckey("[User]-[Message]-[Title]-[world.time]-[rand(1,10000)]"), Title, width, height, src)
	set_content(output)

/datum/browser/listpicker/Topic(href,href_list)
	if (href_list["close"] || !user || !user.client)
		opentime = 0
		return
	if (href_list["button"])
		var/button = text2num(href_list["button"])
		if (button <= 3 && button >= 1)
			selectedbutton = button
	for (var/item in href_list)
		switch(item)
			if ("close", "button", "src")
				continue
			else
				valueslist[item] = href_list[item]
	opentime = 0
	close()

/datum/browser/listpicker/proc/wait()
	while(opentime && selectedbutton <= 0)
		stoplag(1)
