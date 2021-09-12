/mob/proc/target_emote(emote, min_range = null)
	var/datum/click_handler/handler = GetClickHandler()
	if(handler.type == /datum/click_handler/emotes/target_emote)
		to_chat(src, SPAN("notice", "Target selection canceled."))
		usr.PopClickHandler()
	else
		to_chat(src, SPAN("notice", "Select your target."))
		PushClickHandler(/datum/click_handler/emotes/target_emote, list(emote, min_range))

/mob/proc/prepare_target_emote(mob/living/target, parameters)
	var/emote = parameters[1]
	var/min_range = parameters[2]
	if(min_range != null && !(target in view(min_range)))
		to_chat(src, SPAN("warning", "Target is too far."))
		return
	if(target != usr)
		usr.emote("[emote] [target]")
		return
	else
		usr.emote("[emote]")
// HUMAN EMOTES

/mob/proc/emote_pale()
	set name = "Turn pale"
	set category = "Emotes"
	usr.emote("pale")

/mob/proc/emote_laugh()
	set name = "Laugh"
	set category = "Emotes"
	usr.emote("laugh")

/mob/proc/emote_giggle()
	set name = "Giggle"
	set category = "Emotes"
	usr.emote("giggle")

/mob/proc/emote_scream()
	set name = "Scream"
	set category = "Emotes"
	usr.emote("scream")

/mob/proc/emote_long_scream()
	set name = "Long scream"
	set category = "Emotes"
	usr.emote("long_scream")

/mob/proc/emote_blush()
	set name = "Blush"
	set category = "Emotes"
	usr.emote("blush")

/mob/proc/emote_blink()
	set name = "Blink"
	set category = "Emotes"
	usr.emote("blink")

/mob/proc/emote_blink_r()
	set name = "Rapid blink"
	set category = "Emotes"
	usr.emote("blink_r")

/mob/proc/emote_bow()
	set name = "Will bow..."
	set category = "Emotes"
	target_emote("bow")

/mob/proc/emote_chuckle()
	set name = "Chuckle"
	set category = "Emotes"
	usr.emote("chuckle")

/mob/proc/emote_collapse()
	set name = "Collapse"
	set category = "Emotes"
	usr.emote("collapse")

/mob/proc/emote_cough()
	set name = "Cough"
	set category = "Emotes"
	usr.emote("cough")

/mob/proc/emote_cry()
	set name = "Cry"
	set category = "Emotes"
	usr.emote("cry")

/mob/proc/emote_clap()
	set name = "Clap"
	set category = "Emotes"
	usr.emote("clap")

/mob/proc/emote_drool()
	set name = "Droll"
	set category = "Emotes"
	usr.emote("drool")

/mob/proc/emote_faint()
	set name = "Faint"
	set category = "Emotes"
	usr.emote("faint")

/mob/proc/emote_frown()
	set name = "Frown"
	set category = "Emotes"
	usr.emote("frown")

/mob/proc/emote_gasp()
	set name = "Gasp"
	set category = "Emotes"
	usr.emote("gasp")

/mob/proc/emote_groan()
	set name = "Groan"
	set category = "Emotes"
	usr.emote("groan")

/mob/proc/emote_grin()
	set name = "Grin"
	set category = "Emotes"
	usr.emote("grin")

/mob/proc/emote_nod()
	set name = "Nod"
	set category = "Emotes"
	usr.emote("nod")

/mob/proc/emote_moan()
	set name = "Moan"
	set category = "Emotes"
	usr.emote("moan")

/mob/proc/emote_shake()
	set name = "Head shake"
	set category = "Emotes"
	usr.emote("shake")

/mob/proc/emote_sigh()
	set name = "Sigh"
	set category = "Emotes"
	usr.emote("sigh")

/mob/proc/emote_smile()
	set name = "Smile"
	set category = "Emotes"
	usr.emote("smile")

/mob/proc/emote_sneeze()
	set name = "Sneeze"
	set category = "Emotes"
	usr.emote("sneeze")

/mob/proc/emote_grumble()
	set name = "Grumble"
	set category = "Emotes"
	usr.emote("grumble")

/mob/proc/emote_sniff()
	set name = "Sniff"
	set category = "Emotes"
	usr.emote("sniff")

/mob/proc/emote_snore()
	set name = "Snore"
	set category = "Emotes"
	usr.emote("snore")

/mob/proc/emote_shrug()
	set name = "Shrug"
	set category = "Emotes"
	usr.emote("shrug")

/mob/proc/emote_tremble()
	set name = "Tremble in fear"
	set category = "Emotes"
	usr.emote("tremble")

/mob/proc/emote_twitch_v()
	set name = "Twitch violently"
	set category = "Emotes"
	usr.emote("twitch_v")

/mob/proc/emote_twitch()
	set name = "Twitch"
	set category = "Emotes"
	usr.emote("twitch")

/mob/proc/emote_wave()
	set name = "Wave..."
	set category = "Emotes"
	target_emote("wave")

/mob/proc/emote_whimper()
	set name = "Whimper"
	set category = "Emotes"
	usr.emote("whimper")

/mob/proc/emote_wink()
	set name = "Wink"
	set category = "Emotes"
	usr.emote("wink")

/mob/proc/emote_yawn()
	set name = "Yawn"
	set category = "Emotes"
	usr.emote("Yawn")

/mob/proc/emote_salute()
	set name = "Salute..."
	set category = "Emotes"
	target_emote("salute")

/mob/proc/emote_eyebrow()
	set name = "Raise eyebrows"
	set category = "Emotes"
	usr.emote("eyebrow")

/mob/proc/emote_airguitar()
	set name = "Play air guitar"
	set category = "Emotes"
	usr.emote("airguitar")

/mob/proc/emote_mumble()
	set name = "Mumble"
	set category = "Emotes"
	usr.emote("mumble")

/mob/proc/emote_raise()
	set name = "Raise hand"
	set category = "Emotes"
	usr.emote("raise")

/mob/proc/emote_signal()
	set name = "Show several fingers"
	set category = "Emotes"
	var/Cnt = input("", "Show several fingers", 1) in list(1,2,3,4,5)
	usr.emote("signal [Cnt]")

/mob/proc/emote_shiver()
	set name = "Shiver"
	set category = "Emotes"
	usr.emote("shiver")

/mob/proc/emote_dap()
	set name = "Give dap..."
	set category = "Emotes"
	target_emote("dap", 1)

/mob/proc/emote_grunt()
	set name = "Grunt"
	set category = "Emotes"
	usr.emote("grunt")

/mob/proc/emote_look()
	set name = "Look..."
	set category = "Emotes"
	target_emote("look")

/mob/proc/emote_glare()
	set name = "Glare..."
	set category = "Emotes"
	target_emote("glare")

/mob/proc/emote_stare()
	set name = "Stare..."
	set category = "Emotes"
	target_emote("stare")

/mob/proc/emote_vomit()
	set name = "Induce vomit"
	set category = "Emotes"
	visible_message(SPAN("danger", "[src] puts two fingers in his mouth."))
	usr.emote("vomit")

/mob/proc/emote_scratch()
	set name = "Scratch"
	set category = "Emotes"
	usr.emote("scratch")

/mob/proc/emote_jump()
	set name = "Jump"
	set category = "Emotes"
	usr.emote("jump")

/mob/proc/emote_roll()
	set name = "Roll"
	set category = "Emotes"
	usr.emote("roll")

/mob/proc/emote_tail()
	set name = "Wave your tail"
	set category = "Emotes"
	usr.emote("tail")

//	TAIL EMOTES

/mob/proc/emote_swish()
	set name = "> Wave your tail once"
	set category = "Emotes"
	usr.emote("swish")

/mob/proc/emote_wag()
	set name = "> Wave your tail"
	set category = "Emotes"
	usr.emote("wag")

/mob/proc/emote_fastsway()
	set name = "> Wave your tail fast"
	set category = "Emotes"
	usr.emote("fastsway")

/mob/proc/emote_stopsway()
	set name = "> Stop yor tail"
	set category = "Emotes"
	usr.emote("stopsway")

//	ROBOT EMOTES

/mob/living/silicon/robot/verb/emote_beep()
	set name = "Beep"
	set category = "Emotes"
	usr.emote("beep")

/mob/living/silicon/robot/verb/emote_buzz()
	set name = "Buzz"
	set category = "Emotes"
	usr.emote("buzz")

/mob/living/silicon/robot/verb/emote_confirm()
	set name = "Affirmative beep"
	set category = "Emotes"
	usr.emote("confirm")

/mob/living/silicon/robot/verb/emote_deny()
	set name = "Negative beep"
	set category = "Emotes"
	usr.emote("deny")

/mob/living/silicon/robot/verb/emote_ping()
	set name = "Ping"
	set category = "Emotes"
	usr.emote("ping")
