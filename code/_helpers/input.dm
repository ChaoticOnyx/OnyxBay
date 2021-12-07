
/datum/__alert_timeout_processor/proc/process(recipient, message, title, timeout, button1, button2, button3)
	spawn(timeout)
		del(src) // make this proc die if src dies
	return alert(recipient, message, title, button1, button2, button3)

/proc/alert_timeout(recipient, message, title, timeout, button1, button2, button3)
	var/datum/__alert_timeout_processor/processor = new()
	return processor.process(recipient, message, title, timeout, button1, button2, button3)
