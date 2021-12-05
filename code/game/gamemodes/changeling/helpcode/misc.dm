/////////////////
// /mob/ PROCS //
/////////////////

/*/ Transfers mind from wherewher we are into atom/A, moves biostructure in process
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

	BIO.change_host(M) // Biostructure object gets moved here
	mind.changeling.update_my_mob(M)

	if(mind) // It SHOULD exist, but we cannot be completely sure when it comes to changelings code
		if(!istype(M, /mob/living/carbon/brain))
			mind.transfer_to(M) // Moving mind into a mob
		else
			BIO.take_mind_from(src) // Moving mind into a biostructure
	else
		M.key = key // Cringe happened, using hard transfer by key and praying for things to still be repairable

	var/mob/living/carbon/human/H = M
	if(istype(H))
		if(H.stat == DEAD) // Resurrects dead bodies, yet doesn't heal damage
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

	return TRUE*/

