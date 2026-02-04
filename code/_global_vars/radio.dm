

/// List of central command channels, i.e deathsquid & response team.
GLOBAL_LIST_INIT(cencom_frequencies, list(ERT_FREQ, DTH_FREQ))

/// List of antagonist channels, i.e. Syndicate, raiders and etc..
GLOBAL_LIST_INIT(antagonist_frequencies, list(SYND_FREQ, RAID_FREQ))

/// List of department channels, arranged lexically.
GLOBAL_LIST_INIT(department_frequencies, list(
	AI_FREQ,
	COMM_FREQ,
	ENG_FREQ,
	MED_FREQ,
	SEC_FREQ,
	SCI_FREQ,
	SRV_FREQ,
	SUP_FREQ,
	ENT_FREQ
))

/// Associative list of channel name -> channel frequency.
GLOBAL_LIST_INIT(radio_channels, list(
	"Common"		= PUB_FREQ,
	"Science"		= SCI_FREQ,
	"Command"		= COMM_FREQ,
	"Medical"		= MED_FREQ,
	"Engineering"	= ENG_FREQ,
	"Security" 		= SEC_FREQ,
	"Response Team" = ERT_FREQ,
	"Special Ops" 	= DTH_FREQ,
	"Syndicate" 	= SYND_FREQ,
	"Raider"		= RAID_FREQ,
	"Cargo" 		= SUP_FREQ,
	"Provisioning" 	= SRV_FREQ,
	"AI Private"	= AI_FREQ,
	"Entertainment" = ENT_FREQ,
	"Medical(I)"	= MED_I_FREQ,
	"Security(I)"	= SEC_I_FREQ
))
