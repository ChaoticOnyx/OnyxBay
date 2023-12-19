/mob/living/deity
	/// Minds of followers
	var/list/followers = list()

/mob/living/deity/Destroy()
	followers.Cut()
	return ..()

/mob/living/deity/proc/add_follower(mob/living/L)
	if(L.mind && !(L.mind in followers))
		followers.Add(L.mind)
		if(form)
			to_chat(L, SPAN_NOTICE("[form.join_message][src]"))
		deity_net.add_source(L)

/mob/living/deity/proc/remove_follower(mob/living/L)
	if(L.mind && (L.mind in followers))
		followers.Remove(L.mind)
		if(form)
			to_chat(L, SPAN_NOTICE("[form.leave_message][src]"))
		deity_net.remove_source(L)
		//if(L.mind in GLOB.godcult.current_antagonists)
			//GLOB.godcult.remove_cultist(L.mind, src)

/mob/living/deity/proc/get_followers_nearby(atom/target, dist)
	. = list()
	for(var/datum/mind/M in followers)
		if(M.current && get_dist(target, M.current) <= dist)
			. += M.current

/datum/deity_power/phenomena/conversion
	name = "Conversion"
	desc = "Ask a non-follower to convert to your cult. This is completely voluntary."

/datum/deity_power/phenomena/conversion/manifest(mob/living/target, mob/living/deity/D)
	if(!..())
		return FALSE

	if(!target.mind)
		return FALSE

	if(tgui_alert(target, "You feel a calling from the other realm. Would you accept [D.name] as your deity?", "Convert?", list("Yes","No")) == "Yes")
		D.add_follower(target)
