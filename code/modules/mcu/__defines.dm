#define TTS_LANG_GALCOM 0
#define TTS_LANG_EAL 1
#define TTS_LANG_SOL_COMMON 2
#define TTS_LANG_UNATHI 3
#define TTS_LANG_SIIK_MAAS 4
#define TTS_LANG_SKRELLIAN 5
#define TTS_LANG_ROOTLOCAL 6
#define TTS_LANG_ROOTGLOBAL 7
#define TTS_LANG_LUNAR 8
#define TTS_LANG_GUTTER 9
#define TTS_LANG_INDEPENDENT 10
#define TTS_LANG_SPACER 11
#define TTS_LANG_ROBOT 12
#define TTS_LANG_DRONE 13

#define PCI_DEVICE_TYPE_TTS 1
#define PCI_DEVICE_TYPE_LIGHT 2
#define PCI_DEVICE_TYPE_GPS 3
#define PCI_DEVICE_TYPE_ENV_SENSOR 4
#define PCI_DEVICE_TYPE_SIGNALER 5

#define MCU_MODULE_LIST \
	X(/obj/item/mcu_module/tts,          PCI_DEVICE_TYPE_TTS) \
	X(/obj/item/mcu_module/light,        PCI_DEVICE_TYPE_LIGHT) \
	X(/obj/item/mcu_module/gps,          PCI_DEVICE_TYPE_GPS) \
	X(/obj/item/mcu_module/env_sensor,   PCI_DEVICE_TYPE_ENV_SENSOR) \
	X(/obj/item/mcu_module/signaler,   PCI_DEVICE_TYPE_SIGNALER)

#define ENV_SENSOR_ALPHA_RAYS   (1 << 0)
#define ENV_SENSOR_BETA_RAYS    (1 << 1)
#define ENV_SENSOR_HAWKING_RAYS (1 << 2)
