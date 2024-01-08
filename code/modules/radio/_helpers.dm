/proc/frequency_span_class(frequency)
	if(frequency in GLOB.ANTAG_FREQS)
		return "syndradio"

	if(frequency in GLOB.CENT_FREQS)
		return "centradio"

	if(frequency == GLOB.COMM_FREQ)
		return "comradio"

	if(frequency == GLOB.AI_FREQ)
		return "airadio"

	if(frequency == GLOB.SEC_FREQ)
		return "secradio"

	if(frequency == GLOB.ENG_FREQ)
		return "engradio"

	if(frequency == GLOB.SCI_FREQ)
		return "sciradio"

	if(frequency == GLOB.MED_FREQ)
		return "medradio"

	if(frequency == GLOB.SUP_FREQ)
		return "supradio"

	if(frequency == GLOB.SRV_FREQ)
		return "srvradio"

	if(frequency == GLOB.ENT_FREQ)
		return "entradio"

	if(frequency in GLOB.DEPT_FREQS)
		return "deptradio"

	return "radio"
