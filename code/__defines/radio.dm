#define RADIO_LOW_FREQ   1200
#define PUBLIC_LOW_FREQ  1441
#define PUBLIC_HIGH_FREQ 1489
#define RADIO_HIGH_FREQ  1600

#define TRANSMISSION_RADIO    0
#define TRANSMISSION_SUBSPACE 1

#define AI_FREQ   1343
#define DTH_FREQ  1341
#define BOT_FREQ  1447
#define ENT_FREQ  1461
#define ERT_FREQ  1345
#define COMM_FREQ 1353
#define SYND_FREQ 1213
#define RAID_FREQ 1277

// Department channels.
#define PUB_FREQ 1459
#define SEC_FREQ 1359
#define ENG_FREQ 1357
#define MED_FREQ 1355
#define SCI_FREQ 1351
#define SRV_FREQ 1349
#define SUP_FREQ 1347

// Internal department channels (phones).
#define MED_I_FREQ 1485
#define SEC_I_FREQ 1475

/// Special filter 'cause devices belonging to "default" also recieve signals sent to any other filter.
#define RADIO_DEFAULT "radio_default"

#define RADIO_TO_AIRALARM   "radio_airalarm"
#define RADIO_FROM_AIRALARM "radio_airalarm_rcvr"
#define RADIO_CHAT          "radio_telecoms"
#define RADIO_ATMOSIA       "radio_atmos"
#define RADIO_NAVBEACONS    "radio_navbeacon"
#define RADIO_AIRLOCK       "radio_airlock"
#define RADIO_SECBOT        "radio_secbot"
#define RADIO_MULEBOT       "radio_mulebot"
