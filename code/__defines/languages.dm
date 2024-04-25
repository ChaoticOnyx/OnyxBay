// Languages.
#define LANGUAGE_GALCOM "Galactic Common"
#define LANGUAGE_EAL "Encoded Audio Language"
#define LANGUAGE_SOL_COMMON "Sol Common"
#define LANGUAGE_UNATHI "Sinta'unathi"
#define LANGUAGE_SIIK_MAAS "Siik'maas"
#define LANGUAGE_SIIK_TAJR "Siik'tajr"
#define LANGUAGE_SKRELLIAN "Skrellian"
#define LANGUAGE_ROOTLOCAL "Local Rootspeak"
#define LANGUAGE_ROOTGLOBAL "Global Rootspeak"
#define LANGUAGE_LUNAR "Selenian"
#define LANGUAGE_GUTTER "Gutter"
#define LANGUAGE_CULT "Cult"
#define LANGUAGE_SIGN "Sign Language"
#define LANGUAGE_INDEPENDENT "Independent"
#define LANGUAGE_SPACER "Spacer"
#define LANGUAGE_ROBOT "Robot Talk"
#define LANGUAGE_DRONE "Drone Talk"
#define LANGUAGE_LING "Changeling"
#define LANGUAGE_SPIDER "Spider"
#define LANGUAGE_INFERNAL "Infernal"

// Language flags.
/// Language is available if the speaker is whitelisted
#define WHITELISTED  (1<<0)
/// Language can only be acquired by spawning or an admin.
#define RESTRICTED   (1<<1)
/// Language has a significant non-verbal component. Speech is garbled without line-of-sight.
#define NONVERBAL    (1<<2)
/// Language is completely non-verbal. Speech is displayed through emotes for those who can understand.
#define SIGNLANG     (1<<3)
/// Broadcast to all mobs with this language.
#define HIVEMIND     (1<<4)
/// Do not add to general languages list.
#define NONGLOBAL    (1<<5)
/// All mobs can be assumed to speak and understand this language. (audible emotes)
#define INNATE       (1<<6)
/// Do not show the "\The [speaker] talks into \the [radio]" message
#define NO_TALK_MSG  (1<<7)
/// No stuttering, slurring, or other speech problems
#define NO_STUTTER   (1<<8)
/// Language is not based on vision or sound (Todo: add this into the say code and use it for the rootspeak languages)
#define ALT_TRANSMIT (1<<9)
