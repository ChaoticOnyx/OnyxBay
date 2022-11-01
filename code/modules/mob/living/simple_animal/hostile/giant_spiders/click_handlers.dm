
/datum/click_handler/spiders/mob_check(mob/user)
	if(istype(user,/mob/living/simple_animal/hostile/giant_spider))
		return TRUE

/datum/click_handler/spiders/charge/OnClick(atom/target)
	if(mob_check(user))
		var/mob/living/simple_animal/hostile/giant_spider/spider = user
		var/datum/action/cooldown/charge/action = locate() in spider.actions
		spider.PopClickHandler()
		action.ActivateOnClick(target)
		action.active = FALSE

/datum/click_handler/spiders/wrap/OnClick(atom/target)
	if(mob_check(user))
		var/mob/living/simple_animal/hostile/giant_spider/spider = user
		var/datum/action/innate/spider/wrap/action = locate() in spider.actions
		spider.PopClickHandler()
		action.ActivateOnClick(target)
