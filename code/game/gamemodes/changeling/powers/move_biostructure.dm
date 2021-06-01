
/mob/proc/changeling_move_biostructure()
	set category = "Changeling"
	set name = "Move Biostructure"
	set desc = "We relocate our precious organ."

	var/mob/living/carbon/T = src
	if(T)
		T.move_biostructure()

/mob/proc/changeling_transfer_mind(atom/A)
	var/obj/item/organ/internal/biostructure/BIO
	if(istype(src, /mob/living/carbon/brain))
		BIO = loc
	else
		BIO = locate() in contents

	if(!BIO)
		return FALSE

	var/mob/M = A
	if(!M)
		return FALSE

	BIO.change_host(M)

	if(mind)	// basicaly if its mob then mind transfers to mob otherwise creating brain inside of biostucture
		if(!istype(M, /mob/living/carbon/brain))
			mind.transfer_to(M)
		else
			BIO.mind_into_biostructure(src)
	else
		if(istype(M))
			M.key = key

	var/mob/living/carbon/human/H = M
	if(istype(H))
		if(H.stat == DEAD)
			H.setBrainLoss(0)
			H.SetParalysis(0)
			H.SetStunned(0)
			H.SetWeakened(0)
			H.shock_stage = 0
			H.timeofdeath = 0
			H.switch_from_dead_to_living_mob_list()
			var/obj/item/organ/internal/heart/heart = H.internal_organs_by_name[BP_HEART]
			heart.pulse = 1
			H.set_stat(CONSCIOUS)
			H.failed_last_breath = 0 // So mobs that died of oxyloss don't revive and have perpetual out of breath.
			H.reload_fullscreen()
	return TRUE
