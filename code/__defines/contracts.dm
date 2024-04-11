// defines for contract type of impact to station
#define CONTRACT_IMPACT_OPERATION   0x1 // misc value, steal items
#define CONTRACT_IMPACT_MILITARY    0x2 // high likely to meet antagonist with crew, e.g. implant, kill
#define CONTRACT_IMPACT_HIJACK      0x4 // high likely to meet strong defence reaction from crew, e.g. steal active AI
#define CONTRACT_IMPACT_SOCIAL      0x8 // used when contract is designed to solve in rOlEpLaY way, e.g. blood collecting, steal research disk

// defines for steal contract
#define CONTRACT_STEAL_MILITARY   1
#define CONTRACT_STEAL_OPERATION  2
#define CONTRACT_STEAL_SCIENCE    3
#define CONTRACT_STEAL_UNDERPANTS 4

#define CONTRACT_CATEGORY_STEAL      "Steal"
#define CONTRACT_CATEGORY_IMPLANT    "Implant"
#define CONTRACT_CATEGORY_ASSASINATE "Assasinate"
#define CONTRACT_CATEGORY_DUMP       "Dump"
#define CONTRACT_CATEGORY_RECON      "Recon"

GLOBAL_LIST_INIT(contract_categories, list(CONTRACT_CATEGORY_STEAL,
										CONTRACT_CATEGORY_IMPLANT,
										CONTRACT_CATEGORY_ASSASINATE,
										CONTRACT_CATEGORY_DUMP,
										CONTRACT_CATEGORY_RECON
									))
