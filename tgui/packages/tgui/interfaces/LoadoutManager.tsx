import { createSearch } from "common/string";
import { useBackend, useLocalState } from "../backend";
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from "../components";
import { GameIcon } from "../components/GameIcon";
import { Window } from "../layouts";

const MAX_SEARCH_RESULTS = 50;

// --- TypeScript interfaces ---

interface TweakDef {
  index: number;
  type: string;
  currentValue: string;
  options?: string[];
  validColors?: string[];
  contentOptions?: string[][];
  reagentOptions?: string[];
}

interface GearItem {
  name: string;
  hash: string;
  icon: string;
  slot: number;
  slotName: string;
  subgroup: string;
  cost: number;
  price: number;
  discount: number;
  patronTier: string | null;
  description: string;
  allowed: boolean;
  canEquip: boolean;
  tweaks: TweakDef[];
  allowedRoles?: string[];
  whitelisted?: string[];
}

interface GearCategory {
  name: string;
  items: GearItem[];
}

interface SlotInfo {
  slotId: number;
  name: string;
  equippedName?: string | null;
  equippedIcon?: string | null;
}

interface SelectedDetail {
  name: string;
  hash: string;
  tweakedIcon: string | null;
  description: string;
  slot: number;
  slotName: string;
  cost: number;
  price: number;
  discount: number;
  patronTier: string | null;
  canEquip: boolean;
  allowed: boolean;
  equipped: boolean;
}

interface LoadoutData {
  // Static
  categories: GearCategory[];
  allSlotTypes: SlotInfo[];
  maxSlots: number;
  // Dynamic
  equippedGear: Record<string, boolean>;
  selectedHash: string | null;
  selectedItemDetail: SelectedDetail | null;
  selectedTweaks: TweakDef[];
  mannequinIcon: string | null;
  currentSlot: number;
  usedPoints: number;
  maxPoints: number;
  filledSlots: SlotInfo[];
  isTryingOn: boolean;
  hideUnavailable: boolean;
  hideDonate: boolean;
  slotFilter: number | null;
  patronTier: string | null;
  currentOpyxes: number;
}

// --- Slot badge positions on the 96x96 mannequin ---
// These map slot IDs to CSS positions for overlay badges
const SLOT_POSITIONS: Record<number, { top: string; left: string }> = {
  11: { top: "2%", left: "38%" }, // Head
  9: { top: "17%", left: "38%" }, // Eyes/Glasses
  2: { top: "25%", left: "38%" }, // Mask
  8: { top: "12%", left: "70%" }, // Left Ear
  20: { top: "12%", left: "8%" }, // Right Ear
  14: { top: "42%", left: "38%" }, // Uniform
  13: { top: "36%", left: "55%" }, // Suit
  10: { top: "55%", left: "8%" }, // Gloves
  6: { top: "52%", left: "38%" }, // Belt
  1: { top: "33%", left: "8%" }, // Back
  12: { top: "78%", left: "38%" }, // Shoes
  7: { top: "45%", left: "70%" }, // ID
  22: { top: "60%", left: "70%" }, // Accessory
};

// --- Main Component ---

export const LoadoutManager = (props: any, context: any) => {
  const { act, data } = useBackend<LoadoutData>(context);
  const [searchText, setSearchText] = useLocalState(
    context,
    "searchText",
    ""
  );
  const [selectedCategory, setSelectedCategory] = useLocalState(
    context,
    "selectedCategory",
    data.categories?.[0]?.name || ""
  );

  // Get items for current view
  const testSearch = createSearch<GearItem>(searchText, (item) => {
    return item.name + " " + item.description;
  });

  let displayItems: GearItem[] = [];
  if (searchText.length > 0) {
    displayItems = data.categories
      .flatMap((cat) => cat.items || [])
      .filter(testSearch)
      .filter((_, i) => i < MAX_SEARCH_RESULTS);
  } else {
    const currentCat = data.categories.find(
      (cat) => cat.name === selectedCategory
    );
    displayItems = currentCat?.items || [];
  }

  // Apply filters
  if (data.hideUnavailable) {
    displayItems = displayItems.filter(
      (item) => item.allowed || data.equippedGear[item.hash]
    );
  }
  if (data.hideDonate) {
    displayItems = displayItems.filter(
      (item) => !item.price && !item.patronTier
    );
  }
  if (data.slotFilter) {
    displayItems = displayItems.filter(
      (item) => item.slot === data.slotFilter
    );
  }

  return (
    <Window width={820} height={640}>
      <Window.Content>
        <Stack fill>
          {/* Left Column: Categories + Search */}
          <Stack.Item width="160px">
            <Stack fill vertical>
              <Stack.Item>
                <Input
                  fluid
                  placeholder="Search gear..."
                  value={searchText}
                  onInput={(_, value) => setSearchText(value)}
                />
              </Stack.Item>
              <Stack.Item grow>
                {searchText.length === 0 && (
                  <Tabs vertical>
                    {data.categories.map((cat) => (
                      <Tabs.Tab
                        key={cat.name}
                        selected={cat.name === selectedCategory}
                        onClick={() => setSelectedCategory(cat.name)}
                      >
                        {cat.name} ({cat.items?.length || 0})
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                )}
              </Stack.Item>
              <Stack.Item>
                <Divider />
                <Button
                  fluid
                  icon={data.hideUnavailable ? "eye-slash" : "eye"}
                  selected={data.hideUnavailable}
                  onClick={() => act("toggleHideUnavailable")}
                >
                  Hide unavailable
                </Button>
                <Button
                  fluid
                  icon={data.hideDonate ? "eye-slash" : "eye"}
                  selected={data.hideDonate}
                  onClick={() => act("toggleHideDonate")}
                >
                  Hide donator
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Divider vertical />
          </Stack.Item>
          {/* Center Column: Preview + Items */}
          <Stack.Item grow basis={0}>
            <Stack fill vertical>
              {/* Mannequin Preview Area */}
              <Stack.Item>
                <Section
                  title={
                    <Stack align="center" inline>
                      <Stack.Item>
                        <Button
                          icon="chevron-left"
                          onClick={() =>
                            act("setSlot", {
                              slot:
                                data.currentSlot <= 1
                                  ? data.maxSlots
                                  : data.currentSlot - 1,
                            })
                          }
                        />
                      </Stack.Item>
                      <Stack.Item mx={1} bold>
                        {"Set " + data.currentSlot}
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="chevron-right"
                          onClick={() =>
                            act("setSlot", {
                              slot:
                                data.currentSlot >= data.maxSlots
                                  ? 1
                                  : data.currentSlot + 1,
                            })
                          }
                        />
                      </Stack.Item>
                      <Stack.Item mx={2}>
                        <Box
                          inline
                          color={
                            data.usedPoints >= data.maxPoints
                              ? "bad"
                              : "good"
                          }
                          bold
                        >
                          {data.usedPoints}/{data.maxPoints} LP
                        </Box>
                      </Stack.Item>
                      <Stack.Item grow />
                      <Stack.Item>
                        <Button
                          icon="eraser"
                          tooltip="Clear Loadout"
                          onClick={() => act("clearLoadout")}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="dice"
                          tooltip="Random Loadout"
                          onClick={() => act("randomizeLoadout")}
                        />
                      </Stack.Item>
                    </Stack>
                  }
                >
                  <Stack align="center">
                    {/* Mannequin with slot overlays */}
                    <Stack.Item>
                      <MannequinPreview
                        mannequinIcon={data.mannequinIcon}
                        filledSlots={data.filledSlots}
                        allSlotTypes={data.allSlotTypes}
                        slotFilter={data.slotFilter}
                        act={act}
                      />
                    </Stack.Item>
                    {/* Patron info */}
                    <Stack.Item grow ml={1}>
                      <Box color="label" fontSize="11px">
                        {data.patronTier
                          ? `Tier: ${data.patronTier}`
                          : "Not a Patron"}
                      </Box>
                      <Box color="label" fontSize="11px">
                        {data.currentOpyxes} opyx
                        {data.currentOpyxes !== 1 ? "es" : ""}
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              {/* Item Browser */}
              <Stack.Item grow basis={0}>
                <Section fill scrollable title="Gear">
                  <ItemBrowser
                    items={displayItems}
                    equippedGear={data.equippedGear}
                    selectedHash={data.selectedHash}
                    act={act}
                  />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Divider vertical />
          </Stack.Item>
          {/* Right Column: Selected Item Detail */}
          <Stack.Item width="230px">
            <Section fill scrollable title="Details">
              {data.selectedItemDetail ? (
                <ItemDetail
                  detail={data.selectedItemDetail}
                  tweaks={data.selectedTweaks}
                  isTryingOn={data.isTryingOn}
                  act={act}
                />
              ) : (
                <NoticeBox>Select an item to view details.</NoticeBox>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// --- Mannequin Preview Component ---

interface MannequinPreviewProps {
  mannequinIcon: string | null;
  filledSlots: SlotInfo[];
  allSlotTypes: SlotInfo[];
  slotFilter: number | null;
  act: Function;
}

const MannequinPreview = (props: MannequinPreviewProps, context: any) => {
  const { mannequinIcon, filledSlots, allSlotTypes, slotFilter, act } = props;

  // Build a lookup of slot ID -> filled info
  const filledMap: Record<number, SlotInfo> = {};
  for (const slot of filledSlots || []) {
    filledMap[slot.slotId] = slot;
  }

  return (
    <Box
      style={{
        position: "relative",
        width: "108px",
        height: "108px",
      }}
    >
      {/* Mannequin image */}
      {mannequinIcon ? (
        <Box
          as="img"
          src={mannequinIcon.match("src=[\"'](.*)[\"']")?.[1] || ""}
          style={{
            width: "96px",
            height: "96px",
            "image-rendering": "pixelated",
            margin: "6px",
          }}
        />
      ) : (
        <Box
          style={{
            width: "96px",
            height: "96px",
            margin: "6px",
            background: "rgba(255,255,255,0.05)",
          }}
        />
      )}
      {/* Slot badges */}
      {allSlotTypes.map((slot) => {
        const pos = SLOT_POSITIONS[slot.slotId];
        if (!pos) {
          return null;
        }
        const filled = filledMap[slot.slotId];
        const isFiltered = slotFilter === slot.slotId;
        return (
          <Button
            key={slot.slotId}
            tooltip={
              filled
                ? `${slot.name}: ${filled.equippedName}`
                : `${slot.name} (empty)`
            }
            selected={isFiltered}
            color={filled ? "default" : "transparent"}
            style={{
              position: "absolute",
              top: pos.top,
              left: pos.left,
              width: "20px",
              height: "20px",
              "min-width": "20px",
              "min-height": "20px",
              padding: "1px",
              "line-height": "16px",
              "text-align": "center",
              "font-size": "9px",
              opacity: filled ? 1.0 : 0.4,
              "border-radius": "50%",
            }}
            onClick={() => act("setSlotFilter", { slotId: slot.slotId })}
          >
            {filled && filled.equippedIcon ? (
              <GameIcon
                html={filled.equippedIcon}
                style={{ width: "16px", height: "16px" }}
              />
            ) : (
              <Icon name="plus" size={0.7} />
            )}
          </Button>
        );
      })}
    </Box>
  );
};

// --- Item Browser Component ---

interface ItemBrowserProps {
  items: GearItem[];
  equippedGear: Record<string, boolean>;
  selectedHash: string | null;
  act: Function;
}

const ItemBrowser = (props: ItemBrowserProps, context: any) => {
  const { items, equippedGear, selectedHash, act } = props;

  if (!items || items.length === 0) {
    return <NoticeBox>No items to display.</NoticeBox>;
  }

  // Group by subgroup
  const groups: Record<string, GearItem[]> = {};
  const groupOrder: string[] = [];
  for (const item of items) {
    const sg = item.subgroup || "";
    if (!groups[sg]) {
      groups[sg] = [];
      groupOrder.push(sg);
    }
    groups[sg].push(item);
  }

  return (
    <Table>
      {groupOrder.map((sg) => (
        <>
          {sg && (
            <Table.Row key={"header-" + sg}>
              <Table.Cell colSpan={4} bold color="label" py={0.5}>
                {sg}
              </Table.Cell>
            </Table.Row>
          )}
          {groups[sg].map((item) => {
            const isEquipped = equippedGear[item.hash];
            const isSelected = selectedHash === item.hash;
            return (
              <Table.Row
                key={item.hash}
                className="candystripe"
                style={{
                  cursor: "pointer",
                  background: isSelected
                    ? "rgba(255,255,255,0.1)"
                    : undefined,
                }}
                onClick={() => act("selectGear", { hash: item.hash })}
              >
                <Table.Cell collapsing>
                  {item.icon ? (
                    <GameIcon
                      html={item.icon}
                      style={{
                        width: "20px",
                        height: "20px",
                        "vertical-align": "middle",
                      }}
                    />
                  ) : (
                    <Icon name="question" />
                  )}
                </Table.Cell>
                <Table.Cell
                  bold={isEquipped}
                  color={
                    isEquipped
                      ? "good"
                      : item.price
                        ? "gold"
                        : !item.allowed
                          ? "bad"
                          : undefined
                  }
                >
                  {item.name}
                </Table.Cell>
                <Table.Cell collapsing color="label">
                  {item.cost > 0 ? `${item.cost}LP` : ""}
                </Table.Cell>
                <Table.Cell collapsing>
                  {isEquipped && <Icon name="check" color="good" />}
                  {item.price > 0 && !isEquipped && (
                    <Icon name="coins" color="gold" />
                  )}
                </Table.Cell>
              </Table.Row>
            );
          })}
        </>
      ))}
    </Table>
  );
};

// --- Item Detail Component ---

interface ItemDetailProps {
  detail: SelectedDetail;
  tweaks: TweakDef[];
  isTryingOn: boolean;
  act: Function;
}

const ItemDetail = (props: ItemDetailProps, context: any) => {
  const { detail, tweaks, isTryingOn, act } = props;

  return (
    <Stack fill vertical>
      <Stack.Item>
        {/* Item Icon and Name */}
        <Stack align="center">
          {detail.tweakedIcon && (
            <Stack.Item>
              <GameIcon
                html={detail.tweakedIcon}
                style={{
                  width: "64px",
                  height: "64px",
                  "image-rendering": "pixelated",
                }}
              />
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Box bold fontSize="14px">
              {detail.name}
            </Box>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Divider />
      </Stack.Item>
      {/* Info */}
      <Stack.Item>
        {detail.slotName && (
          <Box color="label">
            <b>Slot:</b> {detail.slotName}
          </Box>
        )}
        <Box color="label">
          <b>Cost:</b> {detail.cost} LP
        </Box>
        {detail.price > 0 && (
          <Box color="gold">
            <b>Price:</b>{" "}
            {detail.discount > 0 ? (
              <>
                <s>{detail.price}</s>{" "}
                {Math.round(detail.price * detail.discount)} opyxes (
                {Math.round(detail.discount * 100)}% off!)
              </>
            ) : (
              `${detail.price} opyx${detail.price !== 1 ? "es" : ""}`
            )}
          </Box>
        )}
        {detail.patronTier && (
          <Box color="gold">
            <b>Patron Tier:</b> {detail.patronTier}
          </Box>
        )}
      </Stack.Item>
      {/* Description */}
      {detail.description && (
        <Stack.Item>
          <Box color="label" mt={1} italic>
            {detail.description}
          </Box>
        </Stack.Item>
      )}
      {/* Tweaks */}
      {tweaks && tweaks.length > 0 && (
        <Stack.Item>
          <Divider />
          <Box bold mb={0.5}>
            Options:
          </Box>
          {tweaks.map((tweak) => (
            <TweakControl key={tweak.index} tweak={tweak} act={act} />
          ))}
        </Stack.Item>
      )}
      <Stack.Item grow />
      {/* Action Buttons */}
      <Stack.Item>
        <Divider />
        {detail.canEquip ? (
          <Button
            fluid
            icon={detail.equipped ? "minus" : "plus"}
            color={detail.equipped ? "bad" : "good"}
            onClick={() => act("toggleGear", { hash: detail.hash })}
          >
            {detail.equipped ? "Unequip" : "Equip"}
          </Button>
        ) : (
          <>
            {detail.price > 0 && (
              <Stack>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="shopping-cart"
                    color="gold"
                    onClick={() => act("buyGear", { hash: detail.hash })}
                  >
                    Buy
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="eye"
                    selected={isTryingOn}
                    onClick={() => act("tryOn")}
                  >
                    Try On
                  </Button>
                </Stack.Item>
              </Stack>
            )}
            {!detail.price && !detail.allowed && (
              <NoticeBox danger>
                Not available with your current job/species.
              </NoticeBox>
            )}
          </>
        )}
      </Stack.Item>
    </Stack>
  );
};

// --- Tweak Control Component ---

interface TweakControlProps {
  tweak: TweakDef;
  act: Function;
}

const TweakControl = (props: TweakControlProps, context: any) => {
  const { tweak, act } = props;

  switch (tweak.type) {
    case "color": {
      if (tweak.validColors && tweak.validColors.length > 0) {
        // Color palette: show swatches
        return (
          <Box mb={0.5}>
            <Box color="label" mb={0.5}>
              Color:
            </Box>
            {tweak.validColors.map((color) => (
              <Button
                key={color}
                style={{
                  "background-color": color,
                  width: "20px",
                  height: "20px",
                  "min-width": "20px",
                  display: "inline-block",
                  margin: "1px",
                  border:
                    tweak.currentValue === color
                      ? "2px solid white"
                      : "1px solid rgba(255,255,255,0.3)",
                }}
                onClick={() =>
                  act("setTweak", { tweakIndex: tweak.index, value: color })
                }
              />
            ))}
          </Box>
        );
      }
      // Free color picker: show current color + button to open picker
      return (
        <Box mb={0.5}>
          <Button
            icon="palette"
            onClick={() => act("setTweak", { tweakIndex: tweak.index })}
          >
            Color:{" "}
            <Box
              inline
              style={{
                "background-color": tweak.currentValue,
                width: "14px",
                height: "14px",
                display: "inline-block",
                "vertical-align": "middle",
                border: "1px solid rgba(255,255,255,0.5)",
              }}
            />
          </Button>
        </Box>
      );
    }
    case "path": {
      if (tweak.options && tweak.options.length > 0) {
        return (
          <Box mb={0.5}>
            <Box color="label" mb={0.25}>
              Type:
            </Box>
            <Dropdown
              width="100%"
              selected={tweak.currentValue}
              options={tweak.options}
              onSelected={(value: string) =>
                act("setTweak", { tweakIndex: tweak.index, value })
              }
            />
          </Box>
        );
      }
      return null;
    }
    case "departmental": {
      const entries = tweak.deptEntries || [];
      if (entries.length === 0) {
        return (
          <Box mb={0.5} color="label">
            No department variants available for your selected jobs.
          </Box>
        );
      }
      return (
        <Box mb={0.5}>
          <Box color="label" mb={0.25}>
            Department Variant:
          </Box>
          {entries.map((entry: { label: string; subtype: string }) => (
            <Button
              key={entry.subtype}
              fluid
              icon="building"
              mb={0.25}
              onClick={() =>
                act("setTweak", {
                  tweakIndex: tweak.index,
                  subtype: entry.subtype,
                })
              }
            >
              {entry.label}
            </Button>
          ))}
        </Box>
      );
    }
    case "contents": {
      if (tweak.contentOptions) {
        return (
          <Box mb={0.5}>
            <Box color="label" mb={0.25}>
              Contents:
            </Box>
            {tweak.contentOptions.map((options, i) => (
              <Dropdown
                key={i}
                width="100%"
                selected={tweak.currentValue}
                options={options}
                onSelected={(value: string) =>
                  act("setTweak", { tweakIndex: tweak.index, value })
                }
              />
            ))}
          </Box>
        );
      }
      return null;
    }
    case "reagents": {
      if (tweak.reagentOptions) {
        return (
          <Box mb={0.5}>
            <Box color="label" mb={0.25}>
              Reagent:
            </Box>
            <Dropdown
              width="100%"
              selected={tweak.currentValue}
              options={tweak.reagentOptions}
              onSelected={(value: string) =>
                act("setTweak", { tweakIndex: tweak.index, value })
              }
            />
          </Box>
        );
      }
      return null;
    }
    default: {
      return (
        <Box mb={0.5} color="label">
          {tweak.type}: {tweak.currentValue}
        </Box>
      );
    }
  }
};
