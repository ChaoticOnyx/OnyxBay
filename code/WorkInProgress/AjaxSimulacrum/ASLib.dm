var/ASFileCount = 0

client
	New()
		..()
		src << browse('AjaxSimulacrum.js', "file=AjaxSimulacrum.js;display=0")

atom
	var/list/ProcessInteractionFiles = list( )
	var/list/TickInteractionFiles = list( )
	var/ASTickCount = 0
	var/UpdateCache = ""
	var/ProcessUpdate = 0

	proc
		CreateASWindow(var/atom/User, var/Title, var/BodyHTML)

			if(!ProcessInteractionFiles[User])
				ProcessInteractionFiles[User] = AllocateASFile()
				TickInteractionFiles[User] = AllocateASFile()

			//Push initial files and/or clear existing ones
			ASBegin(0)
			ASFlush(User)
			ASBegin(1)
			ASFlush(User)

			var/Template = "<html><head><title>"
			Template += Title
			Template += "</title>"
			Template += "<script type=\"text/javascript\" src=\"AjaxSimulacrum.js\"></script>"
			Template += "<script type=\"text/javascript\">var ASCore = new AjaxSimulacrumCore(\"[ProcessInteractionFiles[User]]\", \"[TickInteractionFiles[User]]\");</script>"
			Template += "</head><body id=\"BODY\" onload=\"ASCore.Start()\" style=\"cursor: default;\">"
			Template += BodyHTML
			Template += "</HTML>"

			User << browse(Template, "window=\ref[src]")

		CloseASWindow(var/atom/User)
			User << browse(null, "window=\ref[src]")
			ProcessInteractionFiles[User] = null

		AllocateASFile()
			return "DATA[ASFileCount++]"

		ASBegin(var/IsProcess=0)
			ProcessUpdate = IsProcess
			ASTickCount++
			UpdateCache = "<html><body><script type=\"text/javascript\">if (parent.ASCore.CanUpdate([ASTickCount], [IsProcess])) {"

		ASEnd(var/User)
			UpdateCache += "}</script></body></html>"
			User << browse(UpdateCache, "file=[(ProcessUpdate ? ProcessInteractionFiles[User] : TickInteractionFiles[User])];display=0")
			UpdateCache = ""

		SetElementValue(ElementID, NewValue)
			UpdateCache += "parent.ASCore.SetValue(\"[ElementID]\", \"[NewValue]\");"

		SetElementProperty(ElementID, Property, NewValue)
			UpdateCache += "parent.ASCore.SetProperty(\"[ElementID]\", \"[Property]\", \"[NewValue]\");"

		SetElementInnerHTML(ElementID, NewInnerHTML)
			UpdateCache += "parent.ASCore.SetInnerHTML(\"[ElementID]\", \"[NewInnerHTML]\");"

		CallJSFunction(FunctionName, list/Arguments)
			var/Argtext = "\["
			for (var/x = 1; x <= Arguments.len; x++)
				Argtext += "\""
				Argtext += Arguments[x]
				Argtext += "\""
				if (x < Arguments.len)
					Argtext += ", "
			Argtext += "]"
			UpdateCache += "parent.ASCore.CallFunction(\"[FunctionName]\", [Argtext]);"