#define RADIO_LOW_FREQ   1200
#define PUBLIC_LOW_FREQ  1441
#define PUBLIC_HIGH_FREQ 1489
#define RADIO_HIGH_FREQ  1600

#define TRANSMISSION_RADIO    0
#define TRANSMISSION_SUBSPACE 1

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
#define RADIO_MAGNETS       "radio_magnet"
