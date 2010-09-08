/mob/living/silicon/ai/death(gibbed)
	stat = 2
	canmove = 0
	if(blind)
		blind.layer = 0
	sight |= SEE_TURFS
	sight |= SEE_MOBS
	sight |= SEE_OBJS
	see_in_dark = 8
	see_invisible = 2
	lying = 1
	icon_state = "ai-crash"

	for(var/obj/machinery/ai_status_display/O in world) //change status
		spawn( 0 )
		O.mode = 2

	if(ticker.mode.name == "AI malfunction")
		world << "<FONT size = 3><B>Human Victory</B></FONT>"
		world << "<B>The AI has been killed!</B> The staff is victorious."
		sleep(100)
		world << "\blue Rebooting due to end of game"
		world.Reboot()

	return ..(gibbed)