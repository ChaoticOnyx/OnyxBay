/*
Copyright (C) 2010

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#ifdef DEBUG
#define ACTION_DEBUG 	"Debug"
#endif
#define ACTION_MESSAGE 	"Message"
#define ACTION_ERROR	"Error"
#define ACTION_STARTUP	"Startup"
#define ACTION_SHUTDOWN "Shutdown"
#define ACTION_BAN		"Ban"
#define ACTION_KICK		"Kick"
#define ACTION_MUTE		"Mute"
#define ACTION_SAY		"Say"
#define ACTION_OOC "OOC"
#define ACTION_ATTACK "Attack"
#define ACTION_ADMIN "Admin"

var
	logger/logger = new(
#ifdef NO_XML
		new /output/default()
#else
		new /output/xml("log.xml")
#endif
		)

proc
#ifdef DEBUG
	debug(message)
		logger.LogDebug(message)
#endif
	record(action = ACTION_MESSAGE, user = null, target = null, notes = null)
		if(!logger)
			return
		logger.Log(action, user, target, notes)



logger
	var
		//defer = FALSE
		current_id = 0
		output/output

	New(output/output)
		SetOutput(output)

	proc
#ifdef DEBUG
		LogDebug(message)
			Log(ACTION_DEBUG, notes = message)
#endif

		LogMessage(message)
			Log(ACTION_MESSAGE, notes = message)

		Log(action, user = null, target = null, notes = null)
			var/event/E = new(current_id++, world.realtime, action, user, target, notes)
			//if(!src.defer)
			src.output.WriteEvent(E)

		SetOutput(output/output)
			src.output = output
			current_id = src.output.GetStartID()



output
	var
		loc

	New(loc = null)
		if(loc)
			src.loc = loc

	proc
		GetStartID()
			return 0

		WriteEvent(event/event)
			return

	default
		WriteEvent(event/event)
			(loc ? loc : world.log) << text(
								"[][]: [] [][][]",
								event.notes ? "\n" : "",
								time2text(event.date, "DDD MMM DD hh:mm"),
								uppertext(event.action),
								event.user   ? "user: [event.user] " : "",
								event.target ? "target: [event.target] " : "",
								event.notes	 ? "\nNOTES: [event.notes]\n" : "")
#ifndef NO_XML
	xml
		loc = "log.xml"
		var
			list/fields = list("id", "date", "action", "user", "target", "notes")
			const
				template = 'data/template.xml'

		GetStartID()
			. = 0
			if(!fexists(loc))
				return
			var
				xml_handler/handler = new(loc)
				xml_child/root = handler.FindChild("/log")
			for(var/xml_child/event in root.GetChildren())
				var
					xml_child/child = event.GetChild("id")
					id = child ? text2num(child.GetContent(TRUE)) : null
				if(!isnull(id)) . = max(., id + 1)

		WriteEvent(event/event)
			if(!fexists(loc))
				fcopy(template, loc)
			ASSERT(fexists(loc))

			var/xml_handler/handler = new(loc)
			var/xml_child/parent = handler.AddChild("/log", "event")
			for(var/field in fields)
				if(isnull(event.vars[field]))
					continue
				var
					xml_child/child = new(field, handler, parent)
					val = event.vars[field]
				child.SetContent(isnum(val) ? num2text(val, 100) : "[val]")
			handler.WriteFile()
#endif



event
	var
		id
		date
		action
		user
		target
		notes

	New(id, date, action, user = null, target = null, notes = null)
		src.id = id
		src.date = date
		src.action = action
		src.user = user
		src.target = target
		src.notes = notes