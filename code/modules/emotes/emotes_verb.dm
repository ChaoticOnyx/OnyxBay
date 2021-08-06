/mob/living/proc/target_emote(emote, range = null)
	var/avalibe_target = mobs_in_view(range = range, source = usr.client)
	if(length(avalibe_target))
		avalibe_target |= "No target"
		var/target = input("Choose a target for applying emotion", "", null) as null|anything in avalibe_target
		if(target == null)
			return
		if(target == "No target")
			usr.emote("[emote]")
			return
		if(!(target in mobs_in_view(range = range, source = usr.client)))
			to_chat(usr, SPAN("warning", "Target out of range!"))
			return
		usr.emote("[emote] [target]")
	else
		usr.emote("[emote]")

// HUMAN EMOTES

/mob/living/carbon/human/verb/emote_pale()
	set name = "Turn pale"
	set category = "Emotes"
	usr.emote("pale")

/mob/living/carbon/human/verb/emote_laugh()
	set name = "Laugh"
	set category = "Emotes"
	usr.emote("laugh")

/mob/living/carbon/human/verb/emote_giggle()
	set name = "Giggle"
	set category = "Emotes"
	usr.emote("giggle")

/mob/living/carbon/human/verb/emote_scream()
	set name = "Scream"
	set category = "Emotes"
	usr.emote("scream")

/mob/living/carbon/human/verb/emote_long_scream()
	set name = "Long scream"
	set category = "Emotes"
	usr.emote("long_scream")

/mob/living/carbon/human/verb/emote_blush()
	set name = "Blush"
	set category = "Emotes"
	usr.emote("blush")

/mob/living/carbon/human/verb/emote_blink()
	set name = "Blink"
	set category = "Emotes"
	usr.emote("blink")

/mob/living/carbon/human/verb/emote_blink_r()
	set name = "Rapid blink"
	set category = "Emotes"
	usr.emote("blink_r")

/mob/living/carbon/human/verb/emote_bow()
	set name = "Will bow..."
	set category = "Emotes"
	target_emote("bow")

/mob/living/carbon/human/verb/emote_chuckle()
	set name = "Chuckle"
	set category = "Emotes"
	usr.emote("chuckle")

/mob/living/carbon/human/verb/emote_collapse()
	set name = "Collapse"
	set category = "Emotes"
	usr.emote("collapse")

/mob/living/carbon/human/verb/emote_cough()
	set name = "Cough"
	set category = "Emotes"
	usr.emote("cough")

/mob/living/carbon/human/verb/emote_cry()
	set name = "Cry"
	set category = "Emotes"
	usr.emote("cry")

/mob/living/carbon/human/verb/emote_clap()
	set name = "Clap"
	set category = "Emotes"
	usr.emote("clap")

/mob/living/carbon/human/verb/emote_drool()
	set name = "Droll"
	set category = "Emotes"
	usr.emote("drool")

/mob/living/carbon/human/verb/emote_faint()
	set name = "Faint"
	set category = "Emotes"
	usr.emote("faint")

/mob/living/carbon/human/verb/emote_frown()
	set name = "Frown"
	set category = "Emotes"
	usr.emote("frown")

/mob/living/carbon/human/verb/emote_gasp()
	set name = "Gasp"
	set category = "Emotes"
	usr.emote("gasp")

/mob/living/carbon/human/verb/emote_groan()
	set name = "Groan"
	set category = "Emotes"
	usr.emote("groan")

/mob/living/carbon/human/verb/emote_grin()
	set name = "Grin"
	set category = "Emotes"
	usr.emote("grin")

/mob/living/carbon/human/verb/emote_nod()
	set name = "Nod"
	set category = "Emotes"
	usr.emote("nod")

/mob/living/carbon/human/verb/emote_moan()
	set name = "Moan"
	set category = "Emotes"
	usr.emote("moan")

/mob/living/carbon/human/verb/emote_shake()
	set name = "Head shake"
	set category = "Emotes"
	usr.emote("shake")

/mob/living/carbon/human/verb/emote_sigh()
	set name = "Sigh"
	set category = "Emotes"
	usr.emote("sigh")

/mob/living/carbon/human/verb/emote_smile()
	set name = "Smile"
	set category = "Emotes"
	usr.emote("smile")

/mob/living/carbon/human/verb/emote_sneeze()
	set name = "Sneeze"
	set category = "Emotes"
	usr.emote("sneeze")

/mob/living/carbon/human/verb/emote_grumble()
	set name = "Grumble"
	set category = "Emotes"
	usr.emote("grumble")

/mob/living/carbon/human/verb/emote_sniff()
	set name = "Sniff"
	set category = "Emotes"
	usr.emote("sniff")

/mob/living/carbon/human/verb/emote_snore()
	set name = "Snore"
	set category = "Emotes"
	usr.emote("snore")

/mob/living/carbon/human/verb/emote_shrug()
	set name = "Shrug"
	set category = "Emotes"
	usr.emote("shrug")

/mob/living/carbon/human/verb/emote_tremble()
	set name = "Tremble in fear"
	set category = "Emotes"
	usr.emote("tremble")

/mob/living/carbon/human/verb/emote_twitch_v()
	set name = "Twitch violently"
	set category = "Emotes"
	usr.emote("twitch_v")

/mob/living/carbon/human/verb/emote_twitch()
	set name = "Twitch"
	set category = "Emotes"
	usr.emote("twitch")

/mob/living/carbon/human/verb/emote_wave()
	set name = "Wave..."
	set category = "Emotes"
	target_emote("wave")

/mob/living/carbon/human/verb/emote_whimper()
	set name = "Whimper"
	set category = "Emotes"
	usr.emote("whimper")

/mob/living/carbon/human/verb/emote_wink()
	set name = "Wink"
	set category = "Emotes"
	usr.emote("wink")

/mob/living/carbon/human/verb/emote_yawn()
	set name = "Yawn"
	set category = "Emotes"
	usr.emote("Yawn")

/mob/living/carbon/human/verb/emote_salute()
	set name = "Salute..."
	set category = "Emotes"
	target_emote("salute")

/mob/living/carbon/human/verb/emote_eyebrow()
	set name = "Raise eyebrows"
	set category = "Emotes"
	usr.emote("eyebrow")

/mob/living/carbon/human/verb/emote_airguitar()
	set name = "Play air guitar"
	set category = "Emotes"
	usr.emote("airguitar")

/mob/living/carbon/human/verb/emote_mumble()
	set name = "Mumble"
	set category = "Emotes"
	usr.emote("mumble")

/mob/living/carbon/human/verb/emote_raise()
	set name = "Raise hand"
	set category = "Emotes"
	usr.emote("raise")

/mob/living/carbon/human/verb/emote_signal()
	set name = "Show several fingers"
	set category = "Emotes"
	var/Cnt = input("", "Show several fingers", 1) in list(1,2,3,4,5)
	usr.emote("signal [Cnt]")

/mob/living/carbon/human/verb/emote_shiver()
	set name = "Shiver"
	set category = "Emotes"
	usr.emote("shiver")

/mob/living/carbon/human/verb/emote_dap()
	set name = "Give dap..."
	set category = "Emotes"
	target_emote("dap")

/mob/living/carbon/human/verb/emote_grunt()
	set name = "Grunt"
	set category = "Emotes"
	usr.emote("grunt")

/mob/living/carbon/human/verb/emote_look()
	set name = "Look..."
	set category = "Emotes"
	target_emote("look")

/mob/living/carbon/human/verb/emote_vomit()
	set name = "Induce vomit"
	set category = "Emotes"
	visible_message(SPAN("danger", "[src] puts two fingers in his mouth."))
	usr.emote("vomit")

/mob/living/carbon/human/proc/emote_swish()
	set name = "> Wave your tail once"
	set category = "Emotes"
	usr.emote("swish")

/mob/living/carbon/human/proc/emote_wag()
	set name = "> Wave your tail"
	set category = "Emotes"
	usr.emote("wag")

/mob/living/carbon/human/proc/emote_fastsway()
	set name = "> Wave your tail fast"
	set category = "Emotes"
	usr.emote("fastsway")

/mob/living/carbon/human/proc/emote_stopsway()
	set name = "> Stop yor tail"
	set category = "Emotes"
	usr.emote("stopsway")

/mob/living/silicon/robot/verb/emote_beep()
	set name = "Beep"
	set category = "Emotes"
	usr.emote("beep")

/mob/living/silicon/robot/verb/emote_buzz()
	set name = "Buzz"
	set category = "Emotes"
	usr.emote("buzz")

/mob/living/silicon/robot/verb/emote_bow()
	set name = "Will bow..."
	set category = "Emotes"
	target_emote("bow")

/mob/living/silicon/robot/verb/emote_clap()
	set name = "Clap"
	set category = "Emotes"
	usr.emote("clap")

/mob/living/silicon/robot/verb/emote_confirm()
	set name = "Affirmative beep"
	set category = "Emotes"
	usr.emote("confirm")

/mob/living/silicon/robot/verb/emote_deny()
	set name = "Negative beep"
	set category = "Emotes"
	usr.emote("deny")

/mob/living/silicon/robot/verb/emote_look()
	set name = "Look..."
	set category = "Emotes"
	target_emote("look")

/mob/living/silicon/robot/verb/emote_nod()
	set name = "Nod"
	set category = "Emotes"
	usr.emote("nod")

/mob/living/silicon/robot/verb/emote_ping()
	set name = "Ping"
	set category = "Emotes"
	usr.emote("ping")

/mob/living/silicon/robot/verb/emote_salute()
	set name = "Salute..."
	set category = "Emotes"
	target_emote("salute")

/mob/living/silicon/robot/verb/emote_twitch_v()
	set name = "Twitch violently"
	set category = "Emotes"
	usr.emote("twitch_v")

/mob/living/silicon/robot/verb/emote_twitch()
	set name = "Twitch"
	set category = "Emotes"
	usr.emote("twitch")
