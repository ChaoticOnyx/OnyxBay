/obj/machinery/ASTEST
	var/mode = 0
	var/step = 0
	icon = 'computer.dmi'
	icon_state = "power"
	name = "AjaxSimulacrum TEST"
	density = 1

obj/machinery/ASTEST/attack_hand(mob/User as mob)
	CreateASWindow(User, "TEST", "<script>document.MyFunction = function(data) {alert(data);};</script><A href=\"?\ref[src]\">derp</a><input type=\"test\" id=\"BOX\"></input>", 0)

obj/machinery/ASTEST/Topic(href, href_list)
	mode = 1 - mode

	ASBegin(0)

	//alert() can display arrays too, so take advantage of that here
	CallJSFunction("MyFunction", list("Hi", "you clicked a link"))

	ASEnd(usr)

obj/machinery/ASTEST/process()
	step = 1 - step

	for(var/mob/User in range(1, src))
		if(!ProcessInteractionFiles[User])
			continue

		ASBegin(1)

		if (mode)
			SetElementProperty("BODY", "bgColor", step ? "white" : "black")
		else
			SetElementProperty("BODY", "bgColor", step ? "red" : "yellow")

		ASEnd(User)