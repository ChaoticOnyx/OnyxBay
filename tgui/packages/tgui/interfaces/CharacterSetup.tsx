/**
 * CharacterSetup — Sims-style TGUI character preferences window.
 *
 * Three-column layout:
 *   Left:   Category sidebar (vertical tabs with icons)
 *   Center: Large character preview (rotatable mannequin)
 *   Right:  Category-specific option panel
 *
 * Heavy client-side filtering and validation to minimize server round-trips.
 */

import { classes } from "common/react";
import { createSearch } from "common/string";
import { Component } from "inferno";
import { useBackend, useLocalState } from "../backend";
import {
  Box,
  ColorBox,
  Divider,
  Dropdown,
  Icon,
  Input,
  NumberInput,
  Section,
  Slider,
  Stack,
  Table,
  Tabs,
  TextArea,
} from "../components";
import { GameIcon } from "../components/GameIcon";
import { Window } from "../layouts";

// Stamp images for ID card
import stampCap from "../assets/stamps/stamp-cap.png";
import stampCargo from "../assets/stamps/stamp-cargo.png";
import stampCe from "../assets/stamps/stamp-ce.png";
import stampCent from "../assets/stamps/stamp-cent.png";
import stampCmo from "../assets/stamps/stamp-cmo.png";
import stampHop from "../assets/stamps/stamp-hop.png";
import stampHos from "../assets/stamps/stamp-hos.png";
import stampOk from "../assets/stamps/stamp-ok.png";
import stampRd from "../assets/stamps/stamp-rd.png";

// Map departments → department head stamp (always use the head's stamp)
const DEPT_STAMP: Record<string, string> = {
  "Command": stampCap,
  "Security": stampHos,
  "Medical": stampCmo,
  "Engineering": stampCe,
  "Science": stampRd,
  "Cargo": stampCargo,
  "Civilian": stampHop,
  "Supply": stampCargo,
};

const getStampForJob = (job: JobInfo | null): string => {
  if (!job) return stampCent;
  return DEPT_STAMP[job.department] || stampOk;
};

// ================================================================
// Type definitions
// ================================================================

interface SpeciesInfo {
  name: string;
  blurb: string;
  genders: string[];
  min_age: number;
  max_age: number;
  appearance_flags: number;
  body_builds: Record<string, string[]>;
  default_h_style: string;
  default_f_style: string;
  max_skin_tone: number;
  no_lace: boolean;
}

interface HairStyle {
  name: string;
  gender: string;
  species_allowed: string[];
  has_secondary: boolean;
}

interface FacialHairStyle {
  name: string;
  gender: string;
  species_allowed: string[];
}

interface HeightInfo {
  value: number;
  label: string;
}

interface MarkingInfo {
  name: string;
  species_allowed: string[];
}

interface BodyMarking {
  name: string;
  color: string;
}

interface UnderwearCategory {
  name: string;
  items: string[];
}

interface ConfigInfo {
  allow_metadata: boolean;
  use_cortical_stacks: boolean;
  max_name_len: number;
  loadout_slots: number;
  character_slots: number;
}

// Loadout types
interface GearTweakDef {
  index: number;
  type: string;
  currentValue?: string;
  options?: string[];
  validColors?: string[];
}

interface GearItem {
  name: string;
  hash: string;
  icon: string | null;
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
  tweaks: GearTweakDef[];
  allowedRoles?: string[];
  whitelisted?: string[];
}

interface GearCategory {
  name: string;
  items: GearItem[];
}

interface LoadoutSlotType {
  slotId: number;
  name: string;
}

interface SelectedGearDetail {
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
  equipped: boolean;
}

// Augmentation types
interface RobolimbBrand {
  company: string;
  desc: string;
  species_cannot_use: string[];
  restricted_to: string[];
  applies_to_part: string[];
  max_module_size: number;
}

interface OrganModuleDef {
  path: string;
  name: string;
  desc: string;
  allowed_organs: string[];
  module_type: number;
  module_flags: number;
  augment_cost: number;
  loadout_cost: number;
  cpu_power: number;
  cpu_load: number;
  w_class: number;
  allowed_roles: string[];
}

interface BodyPartDef {
  tag: string;
  name: string;
  type: string;
}

// Career types
interface JobInfo {
  title: string;
  department: string;
  color: string;
  head: boolean;
  positions: number;
  spawn_positions: number;
  minimum_character_age: number;
  minimal_player_age: number;
  faction_restricted: boolean;
  alt_titles?: string[];
  status: string;
  available_in_days?: number;
}

interface FallbackOption {
  value: number;
  label: string;
}

// Personality types
interface TraitDef {
  name: string;
  desc: string;
  category: string;
  mutually_exclusive: string[];
}

interface AntagRole {
  id: string;
  name: string;
  status: string;
}

interface GhostRole {
  id: string;
  name: string;
  status: string;
}

interface UplinkSourceDef {
  name: string;
  desc: string;
}

// Background types
interface BankSecurityOption {
  value: number;
  label: string;
  desc: string;
}

interface RelationType {
  name: string;
  desc: string;
}

interface SpeciesLanguageInfo {
  native: string;
  default: string;
  max_alternates: number;
  available: string[];
}

// Settings types
interface ClientPreferenceDef {
  key: string;
  description: string;
  options: string[];
  category: string;
}

interface KeybindingDef {
  name: string;
  full_name: string;
  description: string;
  category: string;
  default_keys: string[];
}

interface CharacterData {
  // Static data (cached)
  species_list: SpeciesInfo[];
  hair_styles: HairStyle[];
  facial_hair_styles: FacialHairStyle[];
  blood_types: string[];
  spawnpoints: string[];
  body_heights: HeightInfo[];
  body_markings_available: MarkingInfo[];
  underwear_categories: UnderwearCategory[];
  backpack_types: string[];
  bgstate_options: string[];
  config: ConfigInfo;
  // Loadout static
  loadout_categories: GearCategory[];
  loadout_slot_types: LoadoutSlotType[];
  // Augmentation static
  robolimb_brands: RobolimbBrand[];
  organ_modules_available: OrganModuleDef[];
  body_parts: BodyPartDef[];
  // Career static
  job_list: JobInfo[];
  fallback_options: FallbackOption[];
  // Personality static
  trait_list: TraitDef[];
  trait_categories: string[];
  antag_roles: AntagRole[];
  ghost_roles: GhostRole[];
  uplink_sources_available: UplinkSourceDef[];
  // Background static
  company_alignments: string[];
  company_name: string;
  home_systems: string[];
  backgrounds: string[];
  religions: string[];
  bank_security_options: BankSecurityOption[];
  flavor_text_parts: string[];
  robot_module_types: string[];
  species_languages: Record<string, SpeciesLanguageInfo>;
  relation_types: RelationType[];
  records_banned: boolean;
  // Settings static
  client_preference_categories: Record<string, ClientPreferenceDef[]>;
  keybinding_categories: Record<string, KeybindingDef[]>;
  // Dynamic data
  preview_icon: string;
  preview_dir: number;
  real_name: string;
  gender: string;
  species: string;
  age: number;
  body: string;
  body_height: number;
  b_type: string;
  spawnpoint: string;
  be_random_name: number;
  metadata: string;
  hair_color: string;
  s_hair_color: string;
  facial_color: string;
  skin_color: string;
  eye_color: string;
  s_tone: number;
  h_style: string;
  f_style: string;
  disabilities: number;
  has_cortical_stack: boolean;
  body_markings: BodyMarking[];
  all_underwear: Record<string, string>;
  backpack: string;
  equip_preview_mob: number;
  bgstate: string;
  default_slot: number;
  is_guest: boolean;
  load_failed: string | null;
  character_slots_info: { slot: number; name: string }[];
  slot_previews?: { slot: number; name: string; preview: string | null }[];
  // Loadout dynamic
  equippedGear: Record<string, boolean>;
  currentGearSlot: number;
  maxLoadoutPoints: number;
  usedLoadoutPoints: number;
  selectedGearHash: string | null;
  selectedGearDetail: SelectedGearDetail | null;
  selectedGearTweaks: GearTweakDef[];
  hideUnavailable: boolean;
  hideDonate: boolean;
  slotFilter: number | null;
  patronTier: string | null;
  currentOpyxes: number;
  // Augmentation dynamic
  organ_data: Record<string, string | null>;
  rlimb_data: Record<string, string | null>;
  selected_organ: string;
  installed_modules: Record<string, string[]>;
  total_aug_points: number;
  max_aug_points: number;
  // Career dynamic
  job_high: string | null;
  job_medium: string[];
  job_low: string[];
  player_alt_titles: Record<string, string>;
  alternate_option: number;
  // Personality dynamic
  traits: string[];
  be_special_role: string[];
  may_be_special_role: string[];
  uplink_source_order: string[];
  // Background dynamic
  nanotrasen_relation: string;
  home_system: string;
  background: string;
  religion: string;
  bank_security: number;
  bank_pin: number;
  med_record: string;
  gen_record: string;
  sec_record: string;
  exploit_record: string;
  memory: string;
  flavor_texts: Record<string, string>;
  flavour_texts_robot: Record<string, string>;
  alternate_languages: string[];
  relations: string[];
  relations_info: Record<string, string>;
  // Settings dynamic
  preference_values: Record<string, string>;
  user_keybindings: Record<string, string[]>;
}

// Appearance flag constants (mirrored from DM)
const HAS_SKIN_TONE_NORMAL = 0x1;
const HAS_SKIN_COLOR = 0x2;
const HAS_UNDERWEAR = 0x8;
const HAS_EYE_COLOR = 0x10;
const HAS_HAIR_COLOR = 0x20;
const HAS_SKIN_TONE_GRAV = 0x80;
const HAS_SKIN_TONE_SPCR = 0x100;
const SECONDARY_HAIR_IS_SKIN = 0x200;
const HAS_A_SKIN_TONE =
  HAS_SKIN_TONE_NORMAL | HAS_SKIN_TONE_GRAV | HAS_SKIN_TONE_SPCR;

// Equipment preview flags
const EQUIP_PREVIEW_LOADOUT = 1;
const EQUIP_PREVIEW_JOB = 2;

// Disability flags
const NEARSIGHTED = 0x1;

// Direction constants
const NORTH = 1;
const SOUTH = 2;
const EAST = 4;
const WEST = 8;

// ================================================================
// Custom button component — replaces default TGUI Button
// ================================================================

const CsButton = (props: {
  icon?: string;
  selected?: boolean;
  compact?: boolean;
  color?: string;
  tooltip?: string;
  disabled?: boolean;
  fluid?: boolean;
  checked?: boolean;
  textAlign?: string;
  width?: string;
  onClick?: (e?) => void;
  children?: any;
  mr?: number;
  ml?: number;
  mt?: number;
  mb?: number;
}) => (
  <Box
    inline={!props.fluid}
    className={classes([
      "CharSetup__btn",
      props.selected && "CharSetup__btn--selected",
      props.compact && "CharSetup__btn--compact",
      props.color && `CharSetup__btn--${props.color}`,
      props.disabled && "CharSetup__btn--disabled",
      props.fluid && "CharSetup__btn--fluid",
      props.checked !== undefined && "CharSetup__btn--checkbox",
      props.checked && "CharSetup__btn--checked",
    ])}
    onClick={props.disabled ? undefined : props.onClick}
    textAlign={props.textAlign}
    width={props.width}
    mr={props.mr}
    ml={props.ml}
    mt={props.mt}
    mb={props.mb}
  >
    {props.checked !== undefined && (
      <Icon
        name={props.checked ? "check-square-o" : "square-o"}
        mr={props.children ? 0.5 : 0}
      />
    )}
    {props.icon && (
      <Icon name={props.icon} mr={props.children ? 0.5 : 0} />
    )}
    {props.children}
  </Box>
);

// ================================================================
// Category definitions
// ================================================================

const CATEGORIES = [
  { id: "identity", label: "Identity", icon: "user" },
  { id: "wardrobe", label: "Wardrobe", icon: "tshirt" },
  { id: "augmentations", label: "Augments", icon: "cog" },
  { id: "career", label: "Career", icon: "briefcase" },
  { id: "personality", label: "Persona", icon: "theater-masks" },
  { id: "background", label: "Lore", icon: "book" },
  { id: "settings", label: "Settings", icon: "sliders-h" },
] as const;

type CategoryId = (typeof CATEGORIES)[number]["id"];

// ================================================================
// Helper: get species info from static data
// ================================================================

function getSpeciesInfo(
  speciesList: SpeciesInfo[],
  speciesName: string
): SpeciesInfo | null {
  return speciesList.find((s) => s.name === speciesName) || null;
}

// ================================================================
// Helper: filter hair styles for species + gender (client-side)
// ================================================================

function getValidHairStyles(
  allStyles: HairStyle[],
  species: string,
  gender: string
): string[] {
  return allStyles
    .filter((s) => {
      if (s.species_allowed && s.species_allowed.length > 0) {
        if (!s.species_allowed.includes(species)) return false;
      }
      return true;
    })
    .map((s) => s.name);
}

function getValidFacialStyles(
  allStyles: FacialHairStyle[],
  species: string,
  gender: string
): string[] {
  return allStyles
    .filter((s) => {
      if (s.species_allowed && s.species_allowed.length > 0) {
        if (!s.species_allowed.includes(species)) return false;
      }
      // Facial hair gender filter: NEUTER is always allowed
      if (s.gender !== "neuter" && s.gender !== gender) return false;
      return true;
    })
    .map((s) => s.name);
}

function getValidMarkings(
  allMarkings: MarkingInfo[],
  species: string
): string[] {
  return allMarkings
    .filter((m) => {
      if (m.species_allowed && m.species_allowed.length > 0) {
        return m.species_allowed.includes(species);
      }
      return true;
    })
    .map((m) => m.name);
}

// ================================================================
// Main component
// ================================================================

export const CharacterSetup = (props, context) => {
  const { act, data } = useBackend<CharacterData>(context);
  const [category, setCategory] = useLocalState<CategoryId>(
    context,
    "category",
    "identity"
  );

  if (data.is_guest) {
    return (
      <Window width={500} height={200}>
        <Window.Content>
          <Section>
            Please create an account to save your preferences. If you have an
            account, please adminhelp for assistance.
          </Section>
        </Window.Content>
      </Window>
    );
  }

  if (data.load_failed) {
    return (
      <Window width={500} height={200}>
        <Window.Content>
          <Section color="bad">
            Loading your savefile failed. Please adminhelp for assistance.
          </Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={1000} height={720}>
      <Window.Content className="CharSetup">
        <Stack fill className="CharSetup__layout">
          {/* Left: Character Card + Category Nav */}
          <Stack.Item>
            <Box className="CharSetup__leftPanel">
              {/* Preview integrated into sidebar */}
              <CharacterPreview data={data} act={act} context={context} />

              {/* Divider between preview and nav */}
              <Box className="CharSetup__navDivider" />

              {/* Category navigation */}
              <CategorySidebar
                selected={category}
                onSelect={setCategory}
                context={context}
              />
            </Box>
          </Stack.Item>

          {/* Right: Category Options Panel */}
          <Stack.Item grow basis={0}>
            <Section
              fill
              scrollable
              title={CATEGORIES.find((c) => c.id === category)?.label}
            >
              <Box key={category} height="100%">
                <CategoryPanel
                  category={category}
                  data={data}
                  act={act}
                  context={context}
                />
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// ================================================================
// Category Sidebar
// ================================================================

const CategorySidebar = (props: {
  selected: CategoryId;
  onSelect: (id: CategoryId) => void;
  context: any;
}) => {
  const { selected, onSelect } = props;
  return (
    <Box className="CharSetup__sidebar">
      {CATEGORIES.map((cat) => (
        <Box
          key={cat.id}
          className={classes([
            "CharSetup__tab",
            `CharSetup__tab--${cat.id}`,
            selected === cat.id && "CharSetup__tab--selected",
          ])}
          onClick={() => onSelect(cat.id)}
        >
          <span className="CharSetup__tabIcon">
            <Icon name={cat.icon} />
          </span>
          {cat.label}
        </Box>
      ))}
    </Box>
  );
};

// ================================================================
// Character Preview (center column)
// ================================================================

const DIR_CYCLE = [SOUTH, WEST, NORTH, EAST];

const rotateDir = (currentDir: number, delta: number): number => {
  const idx = DIR_CYCLE.indexOf(currentDir);
  const next = (idx + delta + DIR_CYCLE.length) % DIR_CYCLE.length;
  return DIR_CYCLE[next];
};

const RotateControls = (props: {
  currentDir: number;
  act: Function;
}) => {
  const { currentDir, act } = props;
  return (
    <Box className="CharSetup__dirControls">
      <CsButton
        compact
        icon="chevron-left"
        onClick={() => act("rotatePreview", { dir: rotateDir(currentDir, -1) })}
      />
      <CsButton
        compact
        icon="chevron-right"
        onClick={() => act("rotatePreview", { dir: rotateDir(currentDir, 1) })}
      />
    </Box>
  );
};

// ================================================================
// Character Slot Selector — with expandable picker overlay
// ================================================================

const CharacterSlotSelector = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const [showPicker, setShowPicker] = useLocalState(context, "showSlotPicker", false);

  const currentSlotName =
    (data.character_slots_info || []).find(
      (s) => s.slot === data.default_slot
    )?.name || `Character ${data.default_slot}`;

  const handleOpenPicker = () => {
    if (!showPicker) {
      act("generateSlotPreviews");
    }
    setShowPicker(!showPicker);
  };

  const handleSelectSlot = (slot: number) => {
    setShowPicker(false);
    if (slot !== data.default_slot) {
      act("loadSlot", { slot });
    }
  };

  return (
    <Box className="CharSetup__slotSelectorWrap">
      <Box className="CharSetup__slotSelector">
        <CsButton
          compact
          icon="chevron-left"
          onClick={() => {
            const maxSlots = data.config.character_slots;
            const prev =
              data.default_slot <= 1 ? maxSlots : data.default_slot - 1;
            act("loadSlot", { slot: prev });
          }}
        />
        <Box
          className="CharSetup__slotName"
          onClick={handleOpenPicker}
          style={{ cursor: "pointer" }}
        >
          <Box className="CharSetup__slotNameLabel">
            {currentSlotName}
            <Icon
              name={showPicker ? "chevron-up" : "chevron-down"}
              ml={0.5}
              style={{ fontSize: "0.625rem", opacity: 0.5 }}
            />
          </Box>
          <Box className="CharSetup__slotNumber">
            {data.default_slot} / {data.config.character_slots}
          </Box>
        </Box>
        <CsButton
          compact
          icon="chevron-right"
          onClick={() => {
            const maxSlots = data.config.character_slots;
            const next =
              data.default_slot >= maxSlots ? 1 : data.default_slot + 1;
            act("loadSlot", { slot: next });
          }}
        />
        <CsButton
          compact
          icon="undo"
          color="bad"
          onClick={() => act("resetSlot")}
        />
      </Box>

      {/* Inline slot picker — pushes sidebar down when open */}
      {showPicker && (
        <Box className="CharSetup__slotPicker">
          <Box className="CharSetup__slotPickerGrid">
            {(data.slot_previews || data.character_slots_info || []).map(
              (slotInfo: any) => {
                const preview = slotInfo.preview || null;
                const isEmpty = !preview;
                const isCurrent = slotInfo.slot === data.default_slot;
                return (
                  <Box
                    key={slotInfo.slot}
                    className={classes([
                      "CharSetup__slotPickerCard",
                      isCurrent && "CharSetup__slotPickerCard--active",
                      isEmpty && "CharSetup__slotPickerCard--empty",
                    ])}
                    onClick={() => handleSelectSlot(slotInfo.slot)}
                  >
                    <Box className="CharSetup__slotPickerPreview">
                      {preview ? (
                        <GameIcon html={preview} />
                      ) : (
                        <Icon
                          name="user-plus"
                          style={{
                            fontSize: "1.5rem",
                            opacity: 0.25,
                          }}
                        />
                      )}
                    </Box>
                    <Box className="CharSetup__slotPickerName">
                      {slotInfo.name}
                    </Box>
                  </Box>
                );
              }
            )}
          </Box>
        </Box>
      )}
    </Box>
  );
};

const CharacterPreview = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act } = props;

  return (
    <Box className="CharSetup__preview">
      {/* Preview sprite */}
      <Box className="CharSetup__previewFrame">
        {data.preview_icon ? (
          <GameIcon html={data.preview_icon} />
        ) : (
          <Box className="CharSetup__previewLoading">
            <Icon name="spinner" spin size={3} />
          </Box>
        )}
      </Box>

      {/* Direction controls — turn left / right */}
      <RotateControls currentDir={data.preview_dir} act={act} />

      {/* Name display */}
      <Box className="CharSetup__previewName">
        {data.real_name}
      </Box>
      <Box className="CharSetup__previewMeta">
        {data.species} &middot; {data.gender === "male" ? "M" : "F"}{" "}
        &middot; {data.age}
      </Box>

      {/* Quick actions + preview toggles — compact row */}
      <Box className="CharSetup__actionRow">
        <CsButton
          compact
          icon="dice"
          onClick={() => act("randomizeAppearance")}
        />
        <CsButton
          compact
          icon="save"
          onClick={() => act("saveSlot")}
        />
        <CsButton
          compact
          icon="tshirt"
          selected={!!(data.equip_preview_mob & EQUIP_PREVIEW_JOB)}
          onClick={() =>
            act("togglePreviewFlag", { flag: EQUIP_PREVIEW_JOB })
          }
        />
        <CsButton
          compact
          icon="box-open"
          selected={!!(data.equip_preview_mob & EQUIP_PREVIEW_LOADOUT)}
          onClick={() =>
            act("togglePreviewFlag", { flag: EQUIP_PREVIEW_LOADOUT })
          }
        />
      </Box>

      {/* Character slot selector */}
      <CharacterSlotSelector data={data} act={act} context={props.context} />
    </Box>
  );
};

// ================================================================
// Category Panel — dispatches to the right sub-panel
// ================================================================

const CategoryPanel = (props: {
  category: CategoryId;
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { category, data, act, context } = props;

  switch (category) {
    case "identity":
      return <IdentityPanel data={data} act={act} context={context} />;
    case "wardrobe":
      return <WardrobePanel data={data} act={act} context={context} />;
    case "augmentations":
      return <AugmentationPanel data={data} act={act} context={context} />;
    case "career":
      return <CareerPanel data={data} act={act} context={context} />;
    case "personality":
      return <PersonalityPanel data={data} act={act} context={context} />;
    case "background":
      return <BackgroundPanel data={data} act={act} context={context} />;
    case "settings":
      return <SettingsPanel data={data} act={act} context={context} />;
    default:
      return null;
  }
};


// ================================================================
// Identity Panel
// ================================================================

const IdentityPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const speciesInfo = getSpeciesInfo(data.species_list, data.species);
  const bodyBuilds = speciesInfo?.body_builds[data.gender] || ["Default"];
  const [showSpeciesInfo, setShowSpeciesInfo] = useLocalState(
    context,
    "showSpeciesInfo",
    false
  );

  // Generate a deterministic "card number" from the character name
  const cardNum = data.real_name
    ? data.real_name.split("").reduce((a, c) => a + c.charCodeAt(0), 0) % 90000 + 10000
    : "00000";

  // Find high-priority job info for card coloring
  const highJob = data.job_high
    ? (data.job_list || []).find((j) => j.title === data.job_high)
    : null;
  const cardColor = highJob?.color || "#d2aa50";
  const cardDept = highJob?.department || null;
  const cardRole = highJob?.title || "Unassigned";

  return (
    <>
    <Box
      className="CharSetup__idCard"
      style={{
        "--id-accent": cardColor,
        borderColor: `${cardColor}22`,
      }}
    >
      {/* Top stripe — colored by department */}
      <Box
        className="CharSetup__idCardStripe"
        style={{
          background: `linear-gradient(90deg, ${cardColor}88 0%, ${cardColor}55 50%, ${cardColor}30 100%)`,
          borderBottomColor: `${cardColor}66`,
        }}
      >
        <Box className="CharSetup__idCardStripeLogo" style={{ color: "#fff" }}>
          <Icon name="atom" mr={0.75} />
          NANOTRASEN CORPORATION
        </Box>
        <Box className="CharSetup__idCardStripeRight" style={{ color: "rgba(255,255,255,0.7)" }}>
          NT-{cardNum}
        </Box>
      </Box>

      {/* Main card body */}
      <Box className="CharSetup__idCardBody">
        {/* Left column: headshot + stamp */}
        <Box className="CharSetup__idCardLeft">
          {/* Headshot photo */}
          <Box className="CharSetup__idCardPhoto">
            <Box className="CharSetup__idCardPhotoInner">
              {data.preview_icon ? (
                <GameIcon
                  html={data.preview_icon}
                  className="CharSetup__idCardHeadshot"
                />
              ) : (
                <Box className="CharSetup__idCardPhotoPlaceholder">
                  <Icon name="user" size={3} />
                </Box>
              )}
            </Box>
            <Box className="CharSetup__idCardPhotoLabel">
              PERSONNEL PHOTO
            </Box>
          </Box>

          {/* Barcode */}
          <Box className="CharSetup__idCardBarcode">
            ||||| ||| || |||| ||| |||||| || |||
          </Box>
        </Box>

        {/* Right column: all editable fields */}
        <Box className="CharSetup__idCardFields">
          {/* Name — big field */}
          <Box className="CharSetup__idCardField">
            <Box className="CharSetup__idCardFieldLabel">Full Name</Box>
            <Stack>
              <Stack.Item grow>
                <Input
                  fluid
                  value={data.real_name}
                  maxLength={data.config.max_name_len}
                  onEnter={(e, val) => act("setName", { name: val })}
                  onChange={(e, val) => act("setName", { name: val })}
                />
              </Stack.Item>
              <Stack.Item>
                <CsButton
                  compact
                  icon="dice"
                  onClick={() => act("randomizeName")}
                />
              </Stack.Item>
            </Stack>
            <CsButton
              mt={0.125}
              checked={!!data.be_random_name}
              onClick={() => act("toggleRandomName")}
            >
              Always randomize
            </CsButton>
          </Box>

          {/* Species + Info */}
          <Box className="CharSetup__idCardField">
            <Box className="CharSetup__idCardFieldLabel">Species</Box>
            <Stack>
              <Stack.Item grow>
                <Dropdown
                  fluid
                  selected={data.species}
                  options={data.species_list.map((s) => s.name)}
                  onSelected={(val) => act("setSpecies", { species: val })}
                />
              </Stack.Item>
              <Stack.Item>
                <CsButton
                  compact
                  icon="info-circle"
                  onClick={() => setShowSpeciesInfo(!showSpeciesInfo)}
                />
              </Stack.Item>
            </Stack>
            {showSpeciesInfo && speciesInfo && (
              <Box className="CharSetup__infoBlurb" mt={0.375}>
                {speciesInfo.blurb || "No description available."}
              </Box>
            )}
          </Box>

          {/* Two-column row: Gender + Age */}
          <Box className="CharSetup__idCardFieldRow">
            <Box className="CharSetup__idCardField" style={{ flex: "1" }}>
              <Box className="CharSetup__idCardFieldLabel">Gender</Box>
              <Box>
                {(speciesInfo?.genders || ["male", "female"]).map((g) => (
                  <CsButton
                    key={g}
                    compact
                    selected={data.gender === g}
                    icon={g === "male" ? "mars" : "venus"}
                    onClick={() => act("setGender", { gender: g })}
                  >
                    {g === "male" ? "Male" : "Female"}
                  </CsButton>
                ))}
              </Box>
            </Box>
            <Box className="CharSetup__idCardField" style={{ flex: "1" }}>
              <Box className="CharSetup__idCardFieldLabel">Age</Box>
              <NumberInput
                value={data.age}
                minValue={speciesInfo?.min_age || 17}
                maxValue={speciesInfo?.max_age || 85}
                step={1}
                onChange={(e, val) => act("setAge", { age: val })}
              />
            </Box>
          </Box>

          {/* Two-column row: Blood Type + Body Build */}
          <Box className="CharSetup__idCardFieldRow">
            <Box className="CharSetup__idCardField" style={{ flex: "1" }}>
              <Box className="CharSetup__idCardFieldLabel">Blood Type</Box>
              <Dropdown
                fluid
                selected={data.b_type}
                options={data.blood_types}
                onSelected={(val) => act("setBloodType", { blood_type: val })}
              />
            </Box>
            <Box className="CharSetup__idCardField" style={{ flex: "1" }}>
              <Box className="CharSetup__idCardFieldLabel">Body Build</Box>
              <Dropdown
                fluid
                selected={data.body}
                options={bodyBuilds}
                onSelected={(val) => act("setBody", { body: val })}
              />
            </Box>
          </Box>

          {/* Height */}
          <Box className="CharSetup__idCardField">
            <Box className="CharSetup__idCardFieldLabel">Height</Box>
            <Box>
              {data.body_heights.map((h) => (
                <CsButton
                  key={h.value}
                  compact
                  selected={data.body_height === h.value}
                  onClick={() => act("setHeight", { height: h.value })}
                >
                  {h.label}
                </CsButton>
              ))}
            </Box>
          </Box>

          {/* OOC Notes */}
          {!!data.config.allow_metadata && (
            <Box className="CharSetup__idCardField">
              <Box className="CharSetup__idCardFieldLabel">OOC Notes</Box>
              <Input
                fluid
                value={data.metadata || ""}
                onEnter={(e, val) => act("setMetadata", { metadata: val })}
                onChange={(e, val) => act("setMetadata", { metadata: val })}
              />
            </Box>
          )}
        </Box>
      </Box>

      {/* Stamp overlay — positioned absolutely over the card */}
      <Box className="CharSetup__idCardStamp">
        <img
          src={getStampForJob(highJob)}
          className="CharSetup__idCardStampImg"
          alt="stamp"
        />
      </Box>

      {/* Bottom edge — card number + role */}
      <Box
        className="CharSetup__idCardFooter"
        style={{ borderTopColor: `${cardColor}14` }}
      >
        <Box>ID: NT-{cardNum}-{data.species?.substring(0, 3).toUpperCase() || "UNK"}</Box>
        <Box style={{ color: `${cardColor}55` }}>
          {cardDept ? `${cardDept.toUpperCase()} — ${cardRole.toUpperCase()}` : "CLEARANCE: PENDING ASSIGNMENT"}
        </Box>
      </Box>
    </Box>

    {/* ── Card backside divider ── */}
    <Box className="CharSetup__idCardDivider">
      <Icon name="rotate" mr={0.5} />
      CARD REVERSE
    </Box>

    {/* ── ID Card Back — Appearance controls ── */}
    <AppearanceCardBack data={data} act={act} context={context} cardColor={cardColor} cardNum={cardNum} />
    </>
  );
};

// ================================================================
// Appearance Card Back — rendered as backside of the ID card
// ================================================================

const AppearanceCardBack = (props: {
  data: CharacterData;
  act: Function;
  context: any;
  cardColor: string;
  cardNum: string | number;
}) => {
  const { data, act, context, cardColor, cardNum } = props;
  const speciesInfo = getSpeciesInfo(data.species_list, data.species);
  const flags = speciesInfo?.appearance_flags || 0;
  const hasHairColor = !!(flags & HAS_HAIR_COLOR);
  const secondaryIsSkin = !!(flags & SECONDARY_HAIR_IS_SKIN);
  const validMarkings = getValidMarkings(
    data.body_markings_available,
    data.species
  );

  const validHairStyles = getValidHairStyles(
    data.hair_styles,
    data.species,
    data.gender
  );
  const validFacialStyles = getValidFacialStyles(
    data.facial_hair_styles,
    data.species,
    data.gender
  );

  const [hairSearch, setHairSearch] = useLocalState(context, "hairSearch", "");
  const [facialSearch, setFacialSearch] = useLocalState(context, "facialSearch", "");

  const filteredHair = hairSearch
    ? validHairStyles.filter((s) => s.toLowerCase().includes(hairSearch.toLowerCase()))
    : validHairStyles;
  const filteredFacial = facialSearch
    ? validFacialStyles.filter((s) => s.toLowerCase().includes(facialSearch.toLowerCase()))
    : validFacialStyles;

  return (
    <Box className="CharSetup__idCardBack">
      {/* Magnetic stripe */}
      <Box className="CharSetup__idCardMagStripe" />

      {/* Main content area */}
      <Box className="CharSetup__idCardBackContent">

        {/* Skin Tone */}
        {!!(flags & HAS_A_SKIN_TONE) && (
          <Box mb={0.75}>
            <Box className="CharSetup__idCardBackLabel">Skin Tone</Box>
            <Slider
              value={-data.s_tone + 35}
              minValue={0}
              maxValue={speciesInfo?.max_skin_tone || 220}
              step={1}
              stepPixelSize={2}
              onChange={(e, val) => act("setSkinTone", { tone: -(val - 35) })}
            />
          </Box>
        )}

        {/* Body Color */}
        {!!(flags & HAS_SKIN_COLOR) && (
          <Box mb={0.75}>
            <Box className="CharSetup__idCardBackLabel">Body Color</Box>
            <Box className="CharSetup__idCardColorRow">
              <Box
                className="CharSetup__idCardColorSwatch"
                style={{ "background-color": data.skin_color }}
              />
              <CsButton
                compact
                icon="palette"
                onClick={() => act("pickColor", { which: "skin" })}
              >
                Change
              </CsButton>
            </Box>
          </Box>
        )}

        {/* Two-column layout: Hair styles (left) + Colors (right) */}
        {(hasHairColor || !!(flags & HAS_EYE_COLOR)) && (
          <Box className="CharSetup__idCardBackColumns" mb={0.75}>
            {/* LEFT — Hair & Facial Style */}
            {hasHairColor && (
              <Box className="CharSetup__idCardBackCol">
                <Box mb={0.75}>
                  <Box className="CharSetup__idCardBackLabel">Hair Style</Box>
                  <Input
                    fluid
                    placeholder="Search styles..."
                    value={hairSearch}
                    onInput={(e, val) => setHairSearch(val)}
                  />
                  <Dropdown
                    fluid
                    mt={0.25}
                    selected={data.h_style}
                    options={filteredHair}
                    onSelected={(val) => act("setHairStyle", { style: val })}
                  />
                  <Box mt={0.25}>
                    <CsButton
                      compact
                      icon="chevron-left"
                      onClick={() => {
                        const idx = validHairStyles.indexOf(data.h_style);
                        const prev = idx <= 0
                          ? validHairStyles[validHairStyles.length - 1]
                          : validHairStyles[idx - 1];
                        act("setHairStyle", { style: prev });
                      }}
                    />
                    <CsButton
                      compact
                      icon="chevron-right"
                      ml={0.25}
                      onClick={() => {
                        const idx = validHairStyles.indexOf(data.h_style);
                        const next = idx >= validHairStyles.length - 1
                          ? validHairStyles[0]
                          : validHairStyles[idx + 1];
                        act("setHairStyle", { style: next });
                      }}
                    />
                  </Box>
                </Box>

                <Box>
                  <Box className="CharSetup__idCardBackLabel">Facial Hair</Box>
                  <Input
                    fluid
                    placeholder="Search styles..."
                    value={facialSearch}
                    onInput={(e, val) => setFacialSearch(val)}
                  />
                  <Dropdown
                    fluid
                    mt={0.25}
                    selected={data.f_style}
                    options={filteredFacial}
                    onSelected={(val) => act("setFacialStyle", { style: val })}
                  />
                </Box>
              </Box>
            )}

            {/* RIGHT — Colors */}
            <Box className="CharSetup__idCardBackCol">
              <Box className="CharSetup__idCardBackLabel">Colors</Box>
              {/* Eye Color */}
              {!!(flags & HAS_EYE_COLOR) && (
                <Box className="CharSetup__idCardColorRow">
                  <Box className="CharSetup__idCardColorLabel">Eye</Box>
                  <Box
                    className="CharSetup__idCardColorSwatch"
                    style={{ "background-color": data.eye_color }}
                  />
                  <CsButton
                    compact
                    icon="palette"
                    onClick={() => act("pickColor", { which: "eyes" })}
                  />
                </Box>
              )}

              {/* Hair Color */}
              {hasHairColor && (
                <Box className="CharSetup__idCardColorRow">
                  <Box className="CharSetup__idCardColorLabel">Hair</Box>
                  <Box
                    className="CharSetup__idCardColorSwatch"
                    style={{ "background-color": data.hair_color }}
                  />
                  <CsButton
                    compact
                    icon="palette"
                    onClick={() => act("pickColor", { which: "hair" })}
                  />
                </Box>
              )}

              {/* Secondary Hair Color */}
              {hasHairColor && !secondaryIsSkin && (
                <Box className="CharSetup__idCardColorRow">
                  <Box className="CharSetup__idCardColorLabel">2nd Hair</Box>
                  <Box
                    className="CharSetup__idCardColorSwatch"
                    style={{ "background-color": data.s_hair_color }}
                  />
                  <CsButton
                    compact
                    icon="palette"
                    onClick={() => act("pickColor", { which: "s_hair" })}
                  />
                </Box>
              )}

              {/* Facial Hair Color */}
              {hasHairColor && (
                <Box className="CharSetup__idCardColorRow">
                  <Box className="CharSetup__idCardColorLabel">Facial</Box>
                  <Box
                    className="CharSetup__idCardColorSwatch"
                    style={{ "background-color": data.facial_color }}
                  />
                  <CsButton
                    compact
                    icon="palette"
                    onClick={() => act("pickColor", { which: "facial" })}
                  />
                </Box>
              )}
            </Box>
          </Box>
        )}

        {/* Body Markings */}
        <Box mb={0.5}>
          <Box className="CharSetup__idCardBackLabel">Body Markings</Box>
          {data.body_markings.map((m) => (
            <Box key={m.name} className="CharSetup__idCardMarkingRow">
              <Box style={{ flex: "1" }}>{m.name}</Box>
              <Box
                className="CharSetup__idCardColorSwatch"
                style={{ "background-color": m.color, width: "1.125rem", height: "1.125rem" }}
              />
              <CsButton
                compact
                icon="palette"
                onClick={() => act("pickMarkingColor", { marking: m.name })}
              />
              <CsButton
                compact
                icon="times"
                color="danger"
                onClick={() => act("removeBodyMarking", { marking: m.name })}
              />
            </Box>
          ))}
          {validMarkings.length > 0 && (
            <Dropdown
              fluid
              mt={0.25}
              displayText="+ Add marking..."
              options={validMarkings.filter(
                (m) => !data.body_markings.find((bm) => bm.name === m)
              )}
              onSelected={(val) => act("addBodyMarking", { marking: val })}
            />
          )}
        </Box>

        {/* Signature strip */}
        <Box className="CharSetup__idCardSignature">
          <Box>NT-{cardNum}</Box>
          <Box>AUTHORIZED PERSONNEL ONLY</Box>
        </Box>
      </Box>
    </Box>
  );
};

// ================================================================
// Wardrobe Panel — Underwear, Backpack, and Integrated Loadout
// ================================================================

const MAX_LOADOUT_SEARCH_RESULTS = 50;

const WardrobePanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  return <LoadoutSubPanel data={data} act={act} context={context} />;
};

// --- Paper-doll slot labels on both sides of the character sprite ---
// Slot labels listed top-to-bottom in a single column beside the sprite.

interface SlotLabel {
  name: string;
  icon: string;
}

const SLOT_LABELS: SlotLabel[] = [
  { name: "Head", icon: "hard-hat" },
  { name: "Eyes", icon: "glasses" },
  { name: "Mask", icon: "theater-masks" },
  { name: "Accessory", icon: "ribbon" },
  { name: "Uniform", icon: "tshirt" },
  { name: "Suit", icon: "vest-patches" },
  { name: "Gloves", icon: "mitten" },
  { name: "Back", icon: "backpack" },
  { name: "Shoes", icon: "shoe-prints" },
];

// --- Paper-doll body selector — character sprite with hoverable hotspot overlays ---

const PaperDollSelector = (props: {
  previewIcon: string | null;
  equippedBySlot: Record<string, GearItem[]>;
  onSelectSlot: (name: string) => void;
  currentDir: number;
  act: Function;
}) => {
  const { previewIcon, equippedBySlot, onSelectSlot, currentDir, act } = props;

  return (
    <Box className="CharSetup__paperDoll">
      {/* Slot list — all slots in one column */}
      <Box className="CharSetup__paperDollSlots">
        {SLOT_LABELS.map((slot) => {
          const equipped = equippedBySlot[slot.name];
          const hasEquipped = equipped && equipped.length > 0;
          return (
            <Box
              key={slot.name}
              className={classes([
                "CharSetup__slotLabel",
                hasEquipped && "CharSetup__slotLabel--equipped",
              ])}
              onClick={() => onSelectSlot(slot.name)}
            >
              {hasEquipped && equipped[0].icon ? (
                <GameIcon
                  html={equipped[0].icon}
                  className="CharSetup__slotLabelIcon"
                />
              ) : (
                <Icon name={slot.icon} className="CharSetup__slotLabelFaIcon" />
              )}
              <Box className="CharSetup__slotLabelText">
                {hasEquipped ? (
                  <>
                    <Box className="CharSetup__slotLabelName">
                      {equipped.length === 1
                        ? equipped[0].name
                        : `${equipped.length} items`}
                    </Box>
                    <Box className="CharSetup__slotLabelSlot">{slot.name}</Box>
                  </>
                ) : (
                  <Box className="CharSetup__slotLabelName">{slot.name}</Box>
                )}
              </Box>
            </Box>
          );
        })}
      </Box>

      {/* Character sprite + rotate controls */}
      <Box className="CharSetup__paperDollRight">
        <Box className="CharSetup__paperDollCenter">
          {previewIcon ? (
            <GameIcon
              html={previewIcon}
              className="CharSetup__paperDollSprite"
            />
          ) : (
            <Box className="CharSetup__paperDollPlaceholder">
              <Icon name="spinner" spin size={3} />
            </Box>
          )}
        </Box>
        <RotateControls currentDir={currentDir} act={act} />
      </Box>
    </Box>
  );
};

// Categories that map directly to body slots — these are accessible via paper-doll
// and hidden from the misc category browser.
const SLOT_CATEGORIES = new Set([
  "Hats", "Glasses", "Masks", "Earwear", "Gloves", "Shoes",
  "Suits", "Uniforms", "Clothing Pieces", "Storage",
]);

// --- Loadout sub-panel (unified wardrobe: underwear + paper-doll + misc) ---

const LoadoutSubPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const [searchText, setSearchText] = useLocalState(
    context,
    "loadoutSearch",
    ""
  );
  const [selectedSlotName, setSelectedSlotName] = useLocalState<string | null>(
    context,
    "loadoutSlotName",
    null
  );
  const [wardrobeView, setWardrobeView] = useLocalState(
    context,
    "wardrobeView",
    "equipment" as "equipment" | "misc"
  );
  // Misc categories — only categories NOT covered by body slots
  const miscCategories = (data.loadout_categories || []).filter(
    (cat) => !SLOT_CATEGORIES.has(cat.name)
  );

  const [selectedCategory, setSelectedCategory] = useLocalState(
    context,
    "loadoutCategory",
    miscCategories.length > 0 ? miscCategories[0].name : ""
  );

  // Build slot name → slotId mapping from data
  const slotNameToId: Record<string, number> = {};
  for (const st of data.loadout_slot_types || []) {
    slotNameToId[st.name] = st.slotId;
  }

  // All items flattened
  const allItems: GearItem[] = (data.loadout_categories || []).flatMap(
    (cat) => cat.items || []
  );

  // Build equipped items by slot name for the body diagram
  const equippedBySlot: Record<string, GearItem[]> = {};
  for (const item of allItems) {
    if (data.equippedGear?.[item.hash]) {
      const slotType = (data.loadout_slot_types || []).find(
        (st) => st.slotId === item.slot
      );
      if (slotType) {
        if (!equippedBySlot[slotType.name]) {
          equippedBySlot[slotType.name] = [];
        }
        equippedBySlot[slotType.name].push(item);
      }
    }
  }

  // Client-side search
  const testSearch = createSearch<GearItem>(searchText, (item) => {
    return item.name + " " + item.description;
  });

  // Determine display items
  let displayItems: GearItem[] = [];
  let showingItems = false;
  if (searchText.length > 0) {
    displayItems = allItems
      .filter(testSearch)
      .filter((_, i) => i < MAX_LOADOUT_SEARCH_RESULTS);
    showingItems = true;
  } else if (wardrobeView === "equipment" && selectedSlotName) {
    const slotId = slotNameToId[selectedSlotName];
    if (slotId !== undefined) {
      displayItems = allItems.filter((item) => item.slot === slotId);
    }
    showingItems = true;
  } else if (wardrobeView === "misc") {
    const currentCat = miscCategories.find(
      (cat) => cat.name === selectedCategory
    );
    displayItems = currentCat?.items || [];
    showingItems = true;
  }

  // Apply client-side filters
  if (data.hideUnavailable) {
    displayItems = displayItems.filter(
      (item) => item.allowed || data.equippedGear?.[item.hash]
    );
  }
  if (data.hideDonate) {
    displayItems = displayItems.filter(
      (item) => !item.price && !item.patronTier
    );
  }

  // Content area — what shows between toolbar and item list
  let middleContent: any = null;
  if (searchText.length > 0) {
    // Search active — no middle content, just item list below
    middleContent = null;
  } else if (wardrobeView === "equipment" && !selectedSlotName) {
    middleContent = (
      <PaperDollSelector
        previewIcon={data.preview_icon}
        equippedBySlot={equippedBySlot}
        onSelectSlot={setSelectedSlotName}
        currentDir={data.preview_dir}
        act={act}
      />
    );
  } else if (wardrobeView === "equipment" && selectedSlotName) {
    middleContent = (
      <Stack align="center" mt={0.5}>
        <Stack.Item>
          <CsButton
            icon="chevron-left"
            onClick={() => {
              setSelectedSlotName(null);
              act("selectGear", { hash: "" });
            }}
          >
            Back
          </CsButton>
        </Stack.Item>
        <Stack.Item grow>
          <Box bold textAlign="center">
            {selectedSlotName}
          </Box>
        </Stack.Item>
      </Stack>
    );
  } else if (wardrobeView === "misc") {
    middleContent = (
      <Tabs mt={0.5}>
        {miscCategories.map((cat) => (
          <Tabs.Tab
            key={cat.name}
            selected={cat.name === selectedCategory}
            onClick={() => setSelectedCategory(cat.name)}
          >
            {cat.name}
          </Tabs.Tab>
        ))}
      </Tabs>
    );
  }

  return (
    <Stack vertical fill>
      {/* Loadout set selector + LP counter */}
      <Stack.Item>
        <Stack align="center">
          <Stack.Item>
            <CsButton
              compact
              icon="chevron-left"
              onClick={() =>
                act("setGearSlot", {
                  slot:
                    data.currentGearSlot <= 1
                      ? data.config.loadout_slots
                      : data.currentGearSlot - 1,
                })
              }
            />
          </Stack.Item>
          <Stack.Item bold mx={0.5}>
            Set {data.currentGearSlot}
          </Stack.Item>
          <Stack.Item>
            <CsButton
              compact
              icon="chevron-right"
              onClick={() =>
                act("setGearSlot", {
                  slot:
                    data.currentGearSlot >= data.config.loadout_slots
                      ? 1
                      : data.currentGearSlot + 1,
                })
              }
            />
          </Stack.Item>
          <Stack.Item grow />
          <Stack.Item>
            <Box
              inline
              bold
              color={
                data.usedLoadoutPoints >= data.maxLoadoutPoints ? "bad" : "good"
              }
            >
              {data.usedLoadoutPoints}/{data.maxLoadoutPoints} LP
            </Box>
          </Stack.Item>
          <Stack.Item>
            <CsButton
              compact
              icon="eraser"
              onClick={() => act("clearLoadout")}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      {/* Underwear + Backpack — compact row */}
      <Stack.Item>
        <Stack align="center" mt={0.5}>
          {data.underwear_categories.map((cat) => (
            <Stack.Item key={cat.name} grow basis={0}>
              <Dropdown
                fluid
                selected={data.all_underwear?.[cat.name] || "None"}
                options={cat.items}
                onSelected={(val) =>
                  act("setUnderwear", { category: cat.name, name: val })
                }
              />
            </Stack.Item>
          ))}
          <Stack.Item grow basis={0}>
            <Dropdown
              fluid
              selected={data.backpack}
              options={data.backpack_types}
              onSelected={(val) => act("setBackpack", { name: val })}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      <Stack.Item>
        <Divider />
      </Stack.Item>

      {/* View tabs: Equipment / Misc + search + filters */}
      <Stack.Item>
        <Stack align="center">
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={wardrobeView === "equipment" && !searchText}
                icon="user"
                onClick={() => {
                  setSearchText("");
                  setWardrobeView("equipment");
                  setSelectedSlotName(null);
                }}
              >
                Equipment
              </Tabs.Tab>
              <Tabs.Tab
                selected={wardrobeView === "misc" && !searchText}
                icon="box-open"
                onClick={() => {
                  setSearchText("");
                  setWardrobeView("misc");
                }}
              >
                Misc
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Input
              fluid
              placeholder="Search all gear..."
              value={searchText}
              onInput={(_, value) => setSearchText(value)}
            />
          </Stack.Item>
          <Stack.Item>
            <CsButton
              compact
              icon={data.hideUnavailable ? "eye-slash" : "eye"}
              selected={data.hideUnavailable}
              onClick={() => act("toggleHideUnavailable")}
            />
          </Stack.Item>
          <Stack.Item>
            <CsButton
              compact
              icon="coins"
              selected={data.hideDonate}
              onClick={() => act("toggleHideDonate")}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      {/* Middle content — paper-doll / back button / misc tabs */}
      <Stack.Item grow={!showingItems && wardrobeView === "equipment" && !selectedSlotName} basis={!showingItems && wardrobeView === "equipment" && !selectedSlotName ? 0 : undefined}>
        {middleContent}
      </Stack.Item>

      {/* Gear item list */}
      <Stack.Item grow basis={0} style={{ overflow: "auto" }}>
        {showingItems && (
          <Box>
            <Divider />
            <LoadoutItemList
              items={displayItems}
              equippedGear={data.equippedGear}
              selectedHash={data.selectedGearHash}
              act={act}
            />
          </Box>
        )}
      </Stack.Item>

      {/* Selected gear detail — only show when viewing items, not on paper-doll */}
      <Stack.Item>
        {showingItems && data.selectedGearDetail && (
          <Box>
            <Divider />
            <LoadoutItemDetail
              detail={data.selectedGearDetail}
              tweaks={data.selectedGearTweaks}
              act={act}
            />
          </Box>
        )}
      </Stack.Item>
    </Stack>
  );
};

// --- Loadout item list ---

const LoadoutItemList = (props: {
  items: GearItem[];
  equippedGear: Record<string, boolean>;
  selectedHash: string | null;
  act: Function;
}) => {
  const { items, equippedGear, selectedHash, act } = props;

  if (!items || items.length === 0) {
    return (
      <Box color="label" textAlign="center" mt={2}>
        No items to display.
      </Box>
    );
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
      {groupOrder.flatMap((sg) => [
        ...(sg
          ? [
              <Table.Row key={"header-" + sg}>
                <Table.Cell colSpan={4} bold color="label" py={0.5}>
                  {sg}
                </Table.Cell>
              </Table.Row>,
            ]
          : []),
        ...groups[sg].map((item) => {
          const isEquipped = equippedGear?.[item.hash];
          const isSelected = selectedHash === item.hash;
          const isUnavailable = !item.canEquip && !item.price;
          return (
            <Table.Row
              key={item.hash}
              className={classes([
                "candystripe",
                "CharSetup__gearRow",
                isSelected && "CharSetup__gearRow--selected",
                isEquipped && "CharSetup__gearRow--equipped",
                isUnavailable && "CharSetup__gearRow--unavailable",
              ])}
              onClick={
                isUnavailable
                  ? undefined
                  : () => act("selectGear", { hash: item.hash })
              }
            >
              <Table.Cell collapsing>
                {item.icon ? (
                  <Box className="CharSetup__gearIcon">
                    <GameIcon html={item.icon} />
                  </Box>
                ) : (
                  <Icon name="question" />
                )}
              </Table.Cell>
              <Table.Cell
                bold={!!isEquipped}
                color={
                  isEquipped
                    ? "good"
                    : item.price
                      ? "gold"
                      : isUnavailable
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
        }),
      ])}
    </Table>
  );
};

// --- Loadout item detail ---

const LoadoutItemDetail = (props: {
  detail: SelectedGearDetail;
  tweaks: GearTweakDef[];
  act: Function;
}) => {
  const { detail, tweaks, act } = props;

  return (
    <Box className="CharSetup__gearDetail">
      {/* Header with icon + name */}
      <Stack align="center" mb={1}>
        {detail.tweakedIcon && (
          <Stack.Item>
            <Box className="CharSetup__gearDetailIcon">
              <GameIcon html={detail.tweakedIcon} />
            </Box>
          </Stack.Item>
        )}
        <Stack.Item grow>
          <Box bold fontSize="13px">
            {detail.name}
          </Box>
          {detail.slotName && (
            <Box color="label" fontSize="11px">
              {detail.slotName} &middot; {detail.cost} LP
            </Box>
          )}
        </Stack.Item>
      </Stack>

      {/* Description */}
      {detail.description && (
        <Box color="label" fontSize="11px" italic mb={1}>
          {detail.description}
        </Box>
      )}

      {/* Price info */}
      {detail.price > 0 && (
        <Box color="gold" fontSize="11px" mb={0.5}>
          {detail.discount > 0 ? (
            <Box as="span">
              <s>{detail.price}</s>{" "}
              {Math.round(detail.price * detail.discount)} opyxes
            </Box>
          ) : (
            `${detail.price} opyx${detail.price !== 1 ? "es" : ""}`
          )}
        </Box>
      )}

      {/* Tweaks */}
      {tweaks && tweaks.length > 0 && (
        <Box mb={1}>
          {tweaks.map((tweak) => (
            <LoadoutTweakControl key={tweak.index} tweak={tweak} act={act} />
          ))}
        </Box>
      )}

      {/* Equip/buy button */}
      {detail.canEquip ? (
        <CsButton
          fluid
          icon={detail.equipped ? "minus" : "plus"}
          color={detail.equipped ? "bad" : "good"}
          onClick={() => act("toggleGear", { hash: detail.hash })}
        >
          {detail.equipped ? "Unequip" : "Equip"}
        </CsButton>
      ) : (
        <Box>
          {detail.price > 0 && (
            <CsButton
              fluid
              icon="shopping-cart"
              color="gold"
              onClick={() => act("buyGear", { hash: detail.hash })}
            >
              Buy
            </CsButton>
          )}
          {!detail.price && (
            <Box color="bad" fontSize="11px">
              Not available with current job/species.
            </Box>
          )}
        </Box>
      )}
    </Box>
  );
};

// --- Loadout tweak controls ---

const LoadoutTweakControl = (props: {
  tweak: GearTweakDef;
  act: Function;
}) => {
  const { tweak, act } = props;

  switch (tweak.type) {
    case "color": {
      if (tweak.validColors && tweak.validColors.length > 0) {
        return (
          <Box mb={0.5}>
            <Box color="label" fontSize="11px" mb={0.25}>
              Color:
            </Box>
            {tweak.validColors.map((color) => (
              <Box
                key={color}
                className={classes([
                  "CharSetup__colorSwatch",
                  tweak.currentValue === color && "CharSetup__colorSwatch--selected",
                ])}
                style={{ "background-color": color }}
                onClick={() =>
                  act("setGearTweak", { tweakIndex: tweak.index, value: color })
                }
              />
            ))}
          </Box>
        );
      }
      return (
        <Box mb={0.5}>
          <CsButton
            icon="palette"
            onClick={() => act("setGearTweak", { tweakIndex: tweak.index })}
          >
            Color:{" "}
            <Box
              inline
              className="CharSetup__colorDot"
              style={{ "background-color": tweak.currentValue }}
            />
          </CsButton>
        </Box>
      );
    }
    case "path": {
      if (tweak.options && tweak.options.length > 0) {
        return (
          <Box mb={0.5}>
            <Box color="label" fontSize="11px" mb={0.25}>
              Type:
            </Box>
            <Dropdown
              width="100%"
              selected={tweak.currentValue}
              options={tweak.options}
              onSelected={(value: string) =>
                act("setGearTweak", { tweakIndex: tweak.index, value })
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
          <Box mb={0.5} color="label" fontSize="11px">
            No department variants available for your selected jobs.
          </Box>
        );
      }
      return (
        <Box mb={0.5}>
          <Box color="label" fontSize="11px" mb={0.25}>
            Department Variant:
          </Box>
          {entries.map((entry: { label: string; subtype: string }) => (
            <CsButton
              key={entry.subtype}
              fluid
              icon="building"
              mb={0.25}
              onClick={() =>
                act("setGearTweak", {
                  tweakIndex: tweak.index,
                  subtype: entry.subtype,
                })
              }
            >
              {entry.label}
            </CsButton>
          ))}
        </Box>
      );
    }
    default: {
      return (
        <Box mb={0.5} color="label" fontSize="11px">
          {tweak.type}: {tweak.currentValue}
        </Box>
      );
    }
  }
};

// ================================================================
// Augmentation Panel — Cyberpunk organ/module interface
// ================================================================

// Icon map for body parts
const ORGAN_ICONS: Record<string, string> = {
  head: "hat-wizard",
  chest: "vest",
  groin: "shield-halved",
  l_arm: "hand-point-left",
  r_arm: "hand-point-right",
  l_hand: "hand",
  r_hand: "hand",
  l_leg: "shoe-prints",
  r_leg: "shoe-prints",
  l_foot: "socks",
  r_foot: "socks",
  heart: "heart-pulse",
  eyes: "eye",
  tongue: "language",
  lungs: "lungs",
  liver: "flask",
  kidneys: "filter",
  brain: "brain",
  stomach: "utensils",
  intestines: "dna",
  bladder: "droplet",
};

// Status label/color helpers
const getOrganStatusLabel = (
  status: string | null,
  tag: string,
  isExternal: boolean,
  brand: string | null
): { label: string; color: string; icon: string } => {
  if (!status)
    return { label: "ORGANIC", color: "#6ec87a", icon: "leaf" };
  if (status === "cyborg")
    return {
      label: brand || "PROSTHETIC",
      color: "#4dc9f6",
      icon: "microchip",
    };
  if (status === "amputated")
    return { label: "AMPUTATED", color: "#f44336", icon: "times-circle" };
  if (status === "mechanical") {
    if (tag === "brain")
      return { label: "POSITRONIC", color: "#4dc9f6", icon: "microchip" };
    return { label: "SYNTHETIC", color: "#4dc9f6", icon: "microchip" };
  }
  if (status === "assisted") {
    if (tag === "heart")
      return { label: "PACEMAKER", color: "#26c6da", icon: "bolt" };
    if (tag === "eyes")
      return { label: "RETINAL OVERLAY", color: "#26c6da", icon: "bolt" };
    if (tag === "brain")
      return { label: "MACHINE-INTERFACE", color: "#26c6da", icon: "bolt" };
    return { label: "ASSISTED", color: "#26c6da", icon: "bolt" };
  }
  return { label: "UNKNOWN", color: "#888", icon: "question" };
};

// Module flag/type constants
const OM_FLAG_BIOLOGICAL = 4;
const OM_FLAG_MECHANICAL = 8;
const OM_TYPE_PROCESSOR = 1;
const OM_TYPE_ACTUATOR = 2;

const AugmentationPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const speciesInfo = getSpeciesInfo(data.species_list, data.species);
  const selectedOrgan = data.selected_organ || "chest";
  const organData = data.organ_data || {};
  const rlimbData = data.rlimb_data || {};
  const installedModules = data.installed_modules || {};

  const externalParts = (data.body_parts || []).filter(
    (bp) => bp.type === "external"
  );
  const internalParts = (data.body_parts || []).filter(
    (bp) => bp.type === "internal"
  );

  const selectedPart = (data.body_parts || []).find(
    (bp) => bp.tag === selectedOrgan
  );
  const isExternal = selectedPart?.type === "external";
  const organStatus = organData[selectedOrgan] || null;
  const organBrand = rlimbData[selectedOrgan] || null;
  const organModules = installedModules[selectedOrgan] || [];

  const validBrands = (data.robolimb_brands || []).filter((brand) => {
    if (
      brand.species_cannot_use &&
      brand.species_cannot_use.includes(data.species)
    )
      return false;
    if (brand.restricted_to && brand.restricted_to.length > 0)
      if (!brand.restricted_to.includes(data.species)) return false;
    if (brand.applies_to_part && brand.applies_to_part.length > 0)
      if (!brand.applies_to_part.includes(selectedOrgan)) return false;
    return true;
  });

  const isCyborg = organStatus === "cyborg";
  const isMechanical = organStatus === "mechanical";
  const isRobotic = isCyborg || isMechanical;

  const highPriorityJob = data.job_high || null;

  // CPU/processor modules are shown under "brain" in the UI but stored under
  // "head" in the data (game code requires BP_HEAD for processors).
  const isProcessor = (mod: any) => mod.module_type === OM_TYPE_PROCESSOR;
  const headModules = installedModules["head"] || [];

  const validModules = (data.organ_modules_available || []).filter((mod) => {
    if (!mod.allowed_organs || mod.allowed_organs.length === 0) return false;
    // Processors: show under brain, not head
    if (isProcessor(mod)) {
      return selectedOrgan === "brain";
    }
    if (!mod.allowed_organs.includes(selectedOrgan)) return false;
    if (isRobotic) {
      if (!(mod.module_flags & OM_FLAG_MECHANICAL)) return false;
    } else {
      if (!(mod.module_flags & OM_FLAG_BIOLOGICAL)) return false;
    }
    if (mod.module_type === OM_TYPE_ACTUATOR) {
      if (
        selectedOrgan === "head" ||
        isCyborg ||
        !["l_arm", "r_arm", "l_hand", "r_hand"].includes(selectedOrgan)
      )
        return false;
    }
    if (selectedOrgan === "eyes" && organStatus !== "mechanical") return false;
    if (mod.allowed_roles && mod.allowed_roles.length > 0) {
      if (!highPriorityJob || !mod.allowed_roles.includes(highPriorityJob)) {
        if (!organModules.includes(mod.path)) return false;
      }
    }
    return true;
  });

  // Aug point ratio for progress bar
  const augRatio =
    data.max_aug_points > 0
      ? Math.min(data.total_aug_points / data.max_aug_points, 1)
      : 0;
  const augOverBudget = data.total_aug_points > data.max_aug_points;

  // Status info for selected organ
  const statusInfo = getOrganStatusLabel(
    organStatus,
    selectedOrgan,
    !!isExternal,
    organBrand
  );

  // Count installed modules across all organs
  const totalInstalledModules = Object.values(installedModules).reduce(
    (sum: number, mods: any) => sum + (Array.isArray(mods) ? mods.length : 0),
    0
  );

  return (
    <Box className="CharSetup__augPanel">
      {/* === TOP HUD BAR === */}
      <Box className="CharSetup__augHud">
        {/* Aug points bar */}
        <Box className="CharSetup__augHudRow">
          <Box className="CharSetup__augHudLabel">
            <Icon name="bolt" mr={0.5} />
            AUG POINTS
          </Box>
          <Box className="CharSetup__augBarWrap">
            <Box
              className={
                "CharSetup__augBarFill" +
                (augOverBudget ? " CharSetup__augBarFill--over" : "")
              }
              style={{ width: `${augRatio * 100}%` }}
            />
            <Box className="CharSetup__augBarText">
              {data.total_aug_points} / {data.max_aug_points}
            </Box>
          </Box>
        </Box>
        {/* Stats row */}
        <Stack className="CharSetup__augHudStats">
          <Stack.Item grow>
            <Icon name="microchip" mr={0.5} />
            {totalInstalledModules} MODULE{totalInstalledModules !== 1
              ? "S"
              : ""}{" "}
            ACTIVE
          </Stack.Item>
          {!!data.config.use_cortical_stacks && (
            <Stack.Item>
              <Box
                as="span"
                className="CharSetup__augLaceChip"
                onClick={() => {
                  if (!speciesInfo?.no_lace) act("toggleCorticalStack");
                }}
              >
                <Icon
                  name={data.has_cortical_stack ? "link" : "unlink"}
                  mr={0.5}
                />
                NEURAL LACE:{" "}
                {speciesInfo?.no_lace
                  ? "N/A"
                  : data.has_cortical_stack
                    ? "ONLINE"
                    : "OFFLINE"}
              </Box>
            </Stack.Item>
          )}
        </Stack>
      </Box>

      {/* === MAIN CONTENT: LEFT selector + RIGHT detail === */}
      <Stack fill className="CharSetup__augBody">
        {/* LEFT — Organ selector */}
        <Stack.Item className="CharSetup__augSelector">
          {/* External */}
          <Box className="CharSetup__augGroupHeader">
            <Icon name="user" mr={0.5} />
            EXTERNAL
          </Box>
          {externalParts.map((bp) => {
            const status = organData[bp.tag];
            const info = getOrganStatusLabel(
              status,
              bp.tag,
              true,
              rlimbData[bp.tag]
            );
            const isSelected = selectedOrgan === bp.tag;
            // Head: subtract CPU modules (they show under Brain)
            const headCpuCount = bp.tag === "head"
              ? (installedModules["head"] || []).filter((p) =>
                  (data.organ_modules_available || []).some(
                    (m) => m.path === p && m.module_type === OM_TYPE_PROCESSOR
                  )).length
              : 0;
            const modCount = (installedModules[bp.tag] || []).length - headCpuCount;
            return (
              <Box
                key={bp.tag}
                className={
                  "CharSetup__augOrganBtn" +
                  (isSelected ? " CharSetup__augOrganBtn--selected" : "")
                }
                onClick={() => act("selectOrgan", { organ: bp.tag })}
              >
                <Icon
                  name={ORGAN_ICONS[bp.tag] || "circle"}
                  className="CharSetup__augOrganIcon"
                  style={{ color: info.color }}
                />
                <Box className="CharSetup__augOrganInfo">
                  <Box className="CharSetup__augOrganName">{bp.name}</Box>
                  <Box
                    className="CharSetup__augOrganStatus"
                    style={{ color: info.color }}
                  >
                    {info.label}
                  </Box>
                </Box>
                {modCount > 0 && (
                  <Box className="CharSetup__augModBadge">{modCount}</Box>
                )}
              </Box>
            );
          })}

          {/* Internal */}
          <Box className="CharSetup__augGroupHeader" mt={0.5}>
            <Icon name="heart-pulse" mr={0.5} />
            INTERNAL
          </Box>
          {internalParts.map((bp) => {
            const status = organData[bp.tag];
            const info = getOrganStatusLabel(
              status,
              bp.tag,
              false,
              null
            );
            const isSelected = selectedOrgan === bp.tag;
            // Brain shows CPU modules stored under head
            const brainCpuCount = bp.tag === "brain"
              ? (installedModules["head"] || []).filter((p) =>
                  (data.organ_modules_available || []).some(
                    (m) => m.path === p && m.module_type === OM_TYPE_PROCESSOR
                  )).length
              : 0;
            const modCount = (installedModules[bp.tag] || []).length + brainCpuCount;
            return (
              <Box
                key={bp.tag}
                className={
                  "CharSetup__augOrganBtn" +
                  (isSelected ? " CharSetup__augOrganBtn--selected" : "")
                }
                onClick={() => act("selectOrgan", { organ: bp.tag })}
              >
                <Icon
                  name={ORGAN_ICONS[bp.tag] || "circle"}
                  className="CharSetup__augOrganIcon"
                  style={{ color: info.color }}
                />
                <Box className="CharSetup__augOrganInfo">
                  <Box className="CharSetup__augOrganName">{bp.name}</Box>
                  <Box
                    className="CharSetup__augOrganStatus"
                    style={{ color: info.color }}
                  >
                    {info.label}
                  </Box>
                </Box>
                {modCount > 0 && (
                  <Box className="CharSetup__augModBadge">{modCount}</Box>
                )}
              </Box>
            );
          })}
        </Stack.Item>

        {/* RIGHT — Detail panel */}
        <Stack.Item grow className="CharSetup__augDetail">
          {selectedPart && (
            <Box>
              {/* Organ header */}
              <Box className="CharSetup__augDetailHeader">
                <Icon
                  name={ORGAN_ICONS[selectedOrgan] || "circle"}
                  className="CharSetup__augDetailIcon"
                  style={{ color: statusInfo.color }}
                />
                <Box>
                  <Box className="CharSetup__augDetailTitle">
                    {selectedPart.name}
                  </Box>
                  <Box
                    className="CharSetup__augDetailStatus"
                    style={{ color: statusInfo.color }}
                  >
                    <Icon name={statusInfo.icon} mr={0.5} />
                    {statusInfo.label}
                  </Box>
                </Box>
              </Box>

              {/* Status controls */}
              <Box className="CharSetup__augSection">
                <Box className="CharSetup__augSectionLabel">
                  <Icon name="sliders-h" mr={0.5} />
                  CONFIGURATION
                </Box>
                <Stack wrap>
                  {isExternal ? (
                    <>
                      <Stack.Item>
                        <Box
                          className={
                            "CharSetup__augChip" +
                            (!organStatus
                              ? " CharSetup__augChip--active"
                              : "")
                          }
                          onClick={() =>
                            act("setOrganStatus", {
                              organ: selectedOrgan,
                              action: "nothing",
                            })
                          }
                        >
                          <Icon name="leaf" mr={0.5} />
                          Organic
                        </Box>
                      </Stack.Item>
                      {selectedOrgan !== "chest" && (
                        <Stack.Item>
                          <Box
                            className={
                              "CharSetup__augChip" +
                              (organStatus === "amputated"
                                ? " CharSetup__augChip--danger"
                                : "")
                            }
                            onClick={() =>
                              act("setOrganStatus", {
                                organ: selectedOrgan,
                                action: "amputated",
                              })
                            }
                          >
                            <Icon name="times-circle" mr={0.5} />
                            Amputated
                          </Box>
                        </Stack.Item>
                      )}
                    </>
                  ) : (
                    <>
                      <Stack.Item>
                        <Box
                          className={
                            "CharSetup__augChip" +
                            (!organStatus
                              ? " CharSetup__augChip--active"
                              : "")
                          }
                          onClick={() =>
                            act("setOrganStatus", {
                              organ: selectedOrgan,
                              action: "nothing",
                            })
                          }
                        >
                          <Icon name="leaf" mr={0.5} />
                          Organic
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Box
                          className={
                            "CharSetup__augChip" +
                            (organStatus === "assisted"
                              ? " CharSetup__augChip--teal"
                              : "")
                          }
                          onClick={() =>
                            act("setOrganStatus", {
                              organ: selectedOrgan,
                              action: "assisted",
                            })
                          }
                        >
                          <Icon name="bolt" mr={0.5} />
                          Assisted
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Box
                          className={
                            "CharSetup__augChip" +
                            (organStatus === "mechanical"
                              ? " CharSetup__augChip--cyber"
                              : "")
                          }
                          onClick={() =>
                            act("setOrganStatus", {
                              organ: selectedOrgan,
                              action: "mechanical",
                            })
                          }
                        >
                          <Icon name="microchip" mr={0.5} />
                          Synthetic
                        </Box>
                      </Stack.Item>
                    </>
                  )}
                </Stack>
              </Box>

              {/* Prosthetic brands */}
              {isExternal && validBrands.length > 0 && (
                <Box className="CharSetup__augSection">
                  <Box className="CharSetup__augSectionLabel">
                    <Icon name="industry" mr={0.5} />
                    PROSTHETIC MANUFACTURER
                  </Box>
                  <Box className="CharSetup__augBrandGrid">
                    {validBrands.map((brand) => (
                      <Box
                        key={brand.company}
                        className={
                          "CharSetup__augBrandCard" +
                          (organBrand === brand.company
                            ? " CharSetup__augBrandCard--selected"
                            : "")
                        }
                        onClick={() =>
                          act("setOrganStatus", {
                            organ: selectedOrgan,
                            action: brand.company,
                          })
                        }
                      >
                        <Box className="CharSetup__augBrandName">
                          {brand.company}
                        </Box>
                        <Box className="CharSetup__augBrandDesc">
                          {brand.desc}
                        </Box>
                      </Box>
                    ))}
                  </Box>
                </Box>
              )}

              {/* Modules */}
              {validModules.length > 0 && (
                <Box className="CharSetup__augSection">
                  <Box className="CharSetup__augSectionLabel">
                    <Icon name="puzzle-piece" mr={0.5} />
                    AVAILABLE IMPLANTS
                  </Box>
                  {validModules.map((mod) => {
                    const modIsProcessor = isProcessor(mod);
                    // Processors are displayed under brain but stored under head
                    const isInstalled = modIsProcessor
                      ? headModules.includes(mod.path)
                      : organModules.includes(mod.path);
                    const costText =
                      mod.loadout_cost > 0
                        ? `${mod.loadout_cost} LP`
                        : mod.augment_cost > 0
                          ? `${mod.augment_cost} AP`
                          : "FREE";
                    const isActuator =
                      mod.module_type === OM_TYPE_ACTUATOR;
                    const typeLabel = modIsProcessor
                      ? "CPU"
                      : isActuator
                        ? "ACTUATOR"
                        : null;
                    return (
                      <Box
                        key={mod.path}
                        className={
                          "CharSetup__augModCard" +
                          (isInstalled
                            ? " CharSetup__augModCard--installed"
                            : "")
                        }
                        onClick={() =>
                          act("toggleOrganModule", {
                            organ: modIsProcessor ? "head" : selectedOrgan,
                            module: mod.path,
                          })
                        }
                      >
                        <Stack align="center">
                          <Stack.Item>
                            <Box
                              className={
                                "CharSetup__augModToggle" +
                                (isInstalled
                                  ? " CharSetup__augModToggle--on"
                                  : "")
                              }
                            >
                              <Icon
                                name={
                                  isInstalled
                                    ? "check-circle"
                                    : "circle"
                                }
                              />
                            </Box>
                          </Stack.Item>
                          <Stack.Item grow>
                            <Box className="CharSetup__augModName">
                              {mod.name}
                              {typeLabel && (
                                <Box
                                  as="span"
                                  className="CharSetup__augModType"
                                >
                                  {typeLabel}
                                </Box>
                              )}
                            </Box>
                            <Box className="CharSetup__augModDesc">
                              {mod.desc}
                            </Box>
                            {mod.allowed_roles &&
                              mod.allowed_roles.length > 0 && (
                                <Box className="CharSetup__augModRoles">
                                  <Icon name="id-badge" mr={0.5} />
                                  {mod.allowed_roles.join(", ")}
                                </Box>
                              )}
                          </Stack.Item>
                          <Stack.Item>
                            <Box className="CharSetup__augModCost">
                              {costText}
                            </Box>
                            {(mod.cpu_power > 0 || mod.cpu_load > 0) && (
                              <Box className="CharSetup__augModCpu">
                                <Icon name="microchip" mr={0.25} />
                                {mod.cpu_power > 0
                                  ? `+${mod.cpu_power}`
                                  : `-${mod.cpu_load}`}
                              </Box>
                            )}
                          </Stack.Item>
                        </Stack>
                      </Box>
                    );
                  })}
                </Box>
              )}
            </Box>
          )}
        </Stack.Item>
      </Stack>
    </Box>
  );
};

// ================================================================
// Career Panel — Job priorities, alt titles, fallback
// ================================================================

// Job priority constants
const JOB_PRIORITY_HIGH = 1;
const JOB_PRIORITY_MEDIUM = 2;
const JOB_PRIORITY_LOW = 3;
const JOB_PRIORITY_NEVER = 4;

function getJobPriority(
  data: CharacterData,
  jobTitle: string
): number {
  if (data.job_high === jobTitle) return JOB_PRIORITY_HIGH;
  if (data.job_medium?.includes(jobTitle)) return JOB_PRIORITY_MEDIUM;
  if (data.job_low?.includes(jobTitle)) return JOB_PRIORITY_LOW;
  return JOB_PRIORITY_NEVER;
}

const PRIORITY_LABELS: Record<number, { text: string; color: string }> = {
  [JOB_PRIORITY_HIGH]: { text: "High", color: "good" },
  [JOB_PRIORITY_MEDIUM]: { text: "Medium", color: "average" },
  [JOB_PRIORITY_LOW]: { text: "Low", color: "bad" },
  [JOB_PRIORITY_NEVER]: { text: "Never", color: "label" },
};

const CareerPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const jobs = data.job_list || [];

  // Group jobs by department (client-side)
  const departments: Record<string, JobInfo[]> = {};
  const deptOrder: string[] = [];
  for (const job of jobs) {
    const dept = job.department || "Other";
    if (!departments[dept]) {
      departments[dept] = [];
      deptOrder.push(dept);
    }
    departments[dept].push(job);
  }

  return (
    <Stack vertical fill>
      {/* Fallback option */}
      <Stack.Item>
        <Box bold mb={0.5}>
          If preferences unavailable:
        </Box>
        <Box>
          {(data.fallback_options || []).map((opt) => (
            <CsButton
              key={opt.value}
              selected={data.alternate_option === opt.value}
              onClick={() =>
                act("setFallbackOption", { option: opt.value })
              }
            >
              {opt.label}
            </CsButton>
          ))}
        </Box>
      </Stack.Item>

      <Stack.Item>
        <Stack>
          <Stack.Item grow />
          <Stack.Item>
            <CsButton
              icon="undo"
              color="bad"
              onClick={() => act("resetJobs")}
            >
              Reset All
            </CsButton>
          </Stack.Item>
        </Stack>
      </Stack.Item>

      <Stack.Item>
        <Divider />
      </Stack.Item>

      {/* Job list grouped by department */}
      <Stack.Item grow basis={0} style={{ overflow: "auto" }}>
        {deptOrder.map((dept) => {
          const deptColor = departments[dept][0]?.color || "#888";
          return (
            <Box
              key={dept}
              className="CharSetup__deptBox"
              mb={0.75}
              style={{
                "border-left": `0.1875rem solid ${deptColor}`,
              }}
            >
              <Box
                className="CharSetup__deptHeader"
                bold
                style={{
                  "background-color": deptColor.replace(")", ", 0.10)").replace("rgb(", "rgba("),
                }}
              >
                {dept}
              </Box>
              {departments[dept].map((job) => {
                const priority = getJobPriority(data, job.title);
                const prioInfo = PRIORITY_LABELS[priority];
                const isAvailable = job.status === "available";
                const statusText = getJobStatusText(job);
                const altTitle =
                  data.player_alt_titles?.[job.title] || job.title;
                const hasAltTitles = isAvailable && job.alt_titles && job.alt_titles.length > 0;

                return (
                  <Box
                    key={job.title}
                    className="CharSetup__jobRow"
                    style={{ opacity: isAvailable ? 1 : 0.5 }}
                  >
                    {/* Job name or alt title dropdown */}
                    <Box className="CharSetup__jobName">
                      {hasAltTitles ? (
                        <Dropdown
                          nochevron={false}
                          color="transparent"
                          selected={altTitle}
                          options={[job.title, ...job.alt_titles]}
                          onSelected={(val: string) =>
                            act("setAltTitle", {
                              job: job.title,
                              title: val,
                            })
                          }
                        />
                      ) : (
                        <Box
                          inline
                          bold={job.head}
                          style={{
                            "text-decoration": !isAvailable
                              ? "line-through"
                              : undefined,
                          }}
                        >
                          {job.title}
                        </Box>
                      )}
                      {statusText && (
                        <Box inline ml={0.5} color="bad" fontSize="10px">
                          [{statusText}]
                        </Box>
                      )}
                    </Box>

                    {/* Priority button */}
                    <Box className="CharSetup__jobPriority">
                      {isAvailable ? (
                        job.title === "Assistant" ? (
                          <CsButton
                            compact
                            color={
                              data.job_low?.includes("Assistant")
                                ? "good"
                                : undefined
                            }
                            onClick={() =>
                              act("switchJobPriority", { job: job.title })
                            }
                          >
                            {data.job_low?.includes("Assistant")
                              ? "Yes"
                              : "No"}
                          </CsButton>
                        ) : (
                          <CsButton
                            compact
                            color={prioInfo.color}
                            onClick={() =>
                              act("switchJobPriority", { job: job.title })
                            }
                          >
                            {prioInfo.text}
                          </CsButton>
                        )
                      ) : null}
                    </Box>
                  </Box>
                );
              })}
            </Box>
          );
        })}
      </Stack.Item>
    </Stack>
  );
};

function getJobStatusText(job: JobInfo): string | null {
  switch (job.status) {
    case "banned":
      return "BANNED";
    case "whitelist":
      return "WHITELIST";
    case "unavailable":
      return "UNAVAILABLE";
    case "too_young_player":
      return `IN ${job.available_in_days} DAYS`;
    case "too_young_char":
      return `MIN AGE: ${job.minimum_character_age}`;
    case "species_restricted":
      return "SPECIES";
    case "faction_restricted":
      return "FACTION";
    default:
      return null;
  }
}

// ================================================================
// Personality Panel — Traits, antag roles, uplink sources
// ================================================================

// ================================================================
// Personality Panel — Medical record styled interface
// ================================================================

// Category icons for trait groups
const TRAIT_CATEGORY_ICONS: Record<string, string> = {
  Physical: "running",
  Mental: "brain",
  Social: "users",
  Neutral: "balance-scale",
};

const PersonalityPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const [personalityTab, setPersonalityTab] = useLocalState(
    context,
    "personalityTab",
    "traits" as "traits" | "antag" | "uplink"
  );

  const tabDefs = [
    {
      id: "traits" as const,
      label: "MEDICAL RECORD",
      icon: "file-medical",
      color: "#81c784",
    },
    {
      id: "antag" as const,
      label: "SECURITY DOSSIER",
      icon: "shield-alt",
      color: "#e57373",
    },
    {
      id: "uplink" as const,
      label: "COMMS CONFIG",
      icon: "satellite-dish",
      color: "#7986cb",
    },
  ];

  return (
    <Box className="CharSetup__medPanel">
      {/* File folder tabs */}
      <Box className="CharSetup__medTabBar">
        {tabDefs.map((tab) => (
          <Box
            key={tab.id}
            className={
              "CharSetup__medTab" +
              (personalityTab === tab.id
                ? " CharSetup__medTab--active"
                : "")
            }
            style={
              personalityTab === tab.id
                ? ({ "--med-accent": tab.color } as any)
                : undefined
            }
            onClick={() => setPersonalityTab(tab.id)}
          >
            <Icon name={tab.icon} mr={0.5} />
            {tab.label}
          </Box>
        ))}
      </Box>

      {/* Document body */}
      <Box className="CharSetup__medBody">
        {personalityTab === "traits" && (
          <TraitsSubPanel data={data} act={act} context={context} />
        )}
        {personalityTab === "antag" && (
          <AntagSubPanel data={data} act={act} />
        )}
        {personalityTab === "uplink" && (
          <UplinkSubPanel data={data} act={act} />
        )}
      </Box>
    </Box>
  );
};

// --- Traits sub-panel — Medical Record ---

const TraitsSubPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const categories = data.trait_categories || [];
  const [traitCategory, setTraitCategory] = useLocalState(
    context,
    "traitCategory",
    categories[0] || "Physical"
  );
  const traits = (data.trait_list || []).filter(
    (t) => t.category === traitCategory
  );
  const currentTraits = data.traits || [];
  const activeCount = currentTraits.length;

  return (
    <>
      {/* Document header */}
      <Box className="CharSetup__medDocHeader">
        <Stack align="center">
          <Stack.Item>
            <Icon
              name="notes-medical"
              className="CharSetup__medDocIcon"
            />
          </Stack.Item>
          <Stack.Item grow>
            <Box className="CharSetup__medDocTitle">
              PERSONNEL MEDICAL ASSESSMENT
            </Box>
            <Box className="CharSetup__medDocSub">
              NANOTRASEN MEDICAL DIVISION // CREW HEALTH EVALUATION
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Box className="CharSetup__medBadge">
              <Icon name="clipboard-check" mr={0.5} />
              {activeCount} NOTED
            </Box>
          </Stack.Item>
        </Stack>
      </Box>

      {/* Category selector as "department tabs" */}
      <Box className="CharSetup__medCatBar">
        {categories.map((cat) => {
          const catTraits = (data.trait_list || []).filter(
            (t) => t.category === cat
          );
          const catActive = catTraits.filter((t) =>
            currentTraits.includes(t.name)
          ).length;
          return (
            <Box
              key={cat}
              className={
                "CharSetup__medCatTab" +
                (traitCategory === cat
                  ? " CharSetup__medCatTab--active"
                  : "")
              }
              onClick={() => setTraitCategory(cat)}
            >
              <Icon
                name={TRAIT_CATEGORY_ICONS[cat] || "tag"}
                mr={0.5}
              />
              {cat}
              {catActive > 0 && (
                <Box as="span" className="CharSetup__medCatCount">
                  {catActive}
                </Box>
              )}
            </Box>
          );
        })}
      </Box>

      {/* Pre-existing conditions */}
      <Box className="CharSetup__medSection">
        <Box className="CharSetup__medSectionHead">
          <Icon name="exclamation-triangle" mr={0.5} />
          PRE-EXISTING CONDITIONS
        </Box>
        <Box
          className={
            "CharSetup__medConditionRow" +
            (data.disabilities & NEARSIGHTED
              ? " CharSetup__medConditionRow--active"
              : "")
          }
          onClick={() => act("toggleDisability", { flag: NEARSIGHTED })}
        >
          <Stack align="center">
            <Stack.Item>
              <Box className="CharSetup__medCondCheck">
                <Icon
                  name={
                    data.disabilities & NEARSIGHTED
                      ? "check-square"
                      : "square"
                  }
                />
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Icon name="eye-slash" mr={0.5} />
              <Box as="span" bold>
                Myopia
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Box className="CharSetup__medCondDesc">
                Subject requires corrective lenses for standard visual
                acuity.
              </Box>
            </Stack.Item>
            {!!(data.disabilities & NEARSIGHTED) && (
              <Stack.Item>
                <Box className="CharSetup__medStamp">CONFIRMED</Box>
              </Stack.Item>
            )}
          </Stack>
        </Box>
      </Box>

      {/* Trait records */}
      <Box className="CharSetup__medSection">
        <Box className="CharSetup__medSectionHead">
          <Icon name="stethoscope" mr={0.5} />
          {traitCategory.toUpperCase()} ASSESSMENT FINDINGS
        </Box>
        <Box className="CharSetup__medTraitList">
          {traits.map((trait) => {
            const isActive = currentTraits.includes(trait.name);
            const hasConflict =
              !isActive &&
              trait.mutually_exclusive.some((excl) =>
                currentTraits.includes(excl)
              );

            return (
              <Box
                key={trait.name}
                className={
                  "CharSetup__medTraitRow" +
                  (isActive ? " CharSetup__medTraitRow--active" : "") +
                  (hasConflict
                    ? " CharSetup__medTraitRow--conflict"
                    : "")
                }
                onClick={() =>
                  act("toggleTrait", { trait: trait.name })
                }
              >
                <Stack align="flex-start">
                  <Stack.Item>
                    <Box
                      className={
                        "CharSetup__medTraitCheck" +
                        (isActive
                          ? " CharSetup__medTraitCheck--on"
                          : "") +
                        (hasConflict
                          ? " CharSetup__medTraitCheck--conflict"
                          : "")
                      }
                    >
                      <Icon
                        name={
                          hasConflict
                            ? "ban"
                            : isActive
                              ? "check-circle"
                              : "circle"
                        }
                      />
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box className="CharSetup__medTraitName">
                      {trait.name}
                      {isActive && (
                        <Box
                          as="span"
                          className="CharSetup__medTraitStamp"
                        >
                          DOCUMENTED
                        </Box>
                      )}
                    </Box>
                    <Box className="CharSetup__medTraitDesc">
                      {trait.desc}
                    </Box>
                    {hasConflict && (
                      <Box className="CharSetup__medTraitConflict">
                        <Icon name="exclamation-circle" mr={0.5} />
                        INCOMPATIBLE:{" "}
                        {trait.mutually_exclusive
                          .filter((excl) =>
                            currentTraits.includes(excl)
                          )
                          .join(", ")}
                      </Box>
                    )}
                  </Stack.Item>
                </Stack>
              </Box>
            );
          })}
        </Box>
      </Box>
    </>
  );
};

// --- Antagonist roles sub-panel — Security Dossier ---

const ANTAG_PRIORITY_LABELS = {
  high: { label: "HIGH", color: "#e57373", icon: "arrow-up" },
  low: { label: "LOW", color: "#ffb74d", icon: "minus" },
  never: { label: "NEVER", color: "#666", icon: "arrow-down" },
};

const AntagSubPanel = (props: {
  data: CharacterData;
  act: Function;
}) => {
  const { data, act } = props;
  const antagRoles = data.antag_roles || [];
  const ghostRoles = data.ghost_roles || [];
  const beSpecial = data.be_special_role || [];
  const mayBeSpecial = data.may_be_special_role || [];

  return (
    <>
      {/* Dossier header */}
      <Box className="CharSetup__medDocHeader CharSetup__medDocHeader--red">
        <Stack align="center">
          <Stack.Item>
            <Icon
              name="user-secret"
              className="CharSetup__medDocIcon"
            />
          </Stack.Item>
          <Stack.Item grow>
            <Box className="CharSetup__medDocTitle">
              THREAT ASSESSMENT PROFILE
            </Box>
            <Box className="CharSetup__medDocSub">
              NANOTRASEN INTERNAL SECURITY // CLASSIFIED
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <Box
                  className="CharSetup__medBulkBtn"
                  onClick={() =>
                    act("setAllAntagPriority", { priority: "high" })
                  }
                >
                  ALL HIGH
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Box
                  className="CharSetup__medBulkBtn"
                  onClick={() =>
                    act("setAllAntagPriority", { priority: "low" })
                  }
                >
                  ALL LOW
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Box
                  className="CharSetup__medBulkBtn"
                  onClick={() =>
                    act("setAllAntagPriority", { priority: "never" })
                  }
                >
                  ALL NEVER
                </Box>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Box>

      {/* Antagonist roles */}
      <Box className="CharSetup__medSection">
        <Box className="CharSetup__medSectionHead CharSetup__medSectionHead--red">
          <Icon name="skull-crossbones" mr={0.5} />
          ANTAGONIST THREAT LEVELS
        </Box>
        {antagRoles.map((role) => {
          const isHigh = beSpecial.includes(role.id);
          const isLow = mayBeSpecial.includes(role.id);
          const isBanned = role.status !== "available";
          const priority = isHigh ? "high" : isLow ? "low" : "never";

          return (
            <Box
              key={role.id}
              className={
                "CharSetup__medAntagRow" +
                (isHigh ? " CharSetup__medAntagRow--high" : "") +
                (isLow ? " CharSetup__medAntagRow--low" : "")
              }
            >
              <Stack align="center">
                <Stack.Item grow>
                  <Box className="CharSetup__medAntagName">
                    {role.name}
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  {isBanned ? (
                    <Box className="CharSetup__medAntagBanned">
                      <Icon name="lock" mr={0.5} />
                      {role.status === "whitelist"
                        ? "RESTRICTED"
                        : "REVOKED"}
                    </Box>
                  ) : (
                    <Stack>
                      {(["high", "low", "never"] as const).map((p) => {
                        const info =
                          ANTAG_PRIORITY_LABELS[p];
                        const isSelected = priority === p;
                        return (
                          <Stack.Item key={p}>
                            <Box
                              className={
                                "CharSetup__medAntagPrio" +
                                (isSelected
                                  ? " CharSetup__medAntagPrio--active"
                                  : "")
                              }
                              style={
                                isSelected
                                  ? { color: info.color, borderColor: info.color }
                                  : undefined
                              }
                              onClick={() =>
                                act("setAntagPriority", {
                                  role: role.id,
                                  priority: p,
                                })
                              }
                            >
                              <Icon name={info.icon} mr={0.25} />
                              {info.label}
                            </Box>
                          </Stack.Item>
                        );
                      })}
                    </Stack>
                  )}
                </Stack.Item>
              </Stack>
            </Box>
          );
        })}
      </Box>

      {/* Ghost roles */}
      {ghostRoles.length > 0 && (
        <Box className="CharSetup__medSection">
          <Box className="CharSetup__medSectionHead CharSetup__medSectionHead--red">
            <Icon name="ghost" mr={0.5} />
            OBSERVER ROLE CLEARANCE
          </Box>
          {ghostRoles.map((role) => {
            const isActive =
              beSpecial.includes(role.id) ||
              mayBeSpecial.includes(role.id);
            const isBanned = role.status !== "available";

            return (
              <Box
                key={role.id}
                className={
                  "CharSetup__medAntagRow" +
                  (isActive ? " CharSetup__medAntagRow--high" : "")
                }
              >
                <Stack align="center">
                  <Stack.Item grow>
                    <Box className="CharSetup__medAntagName">
                      {role.name}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    {isBanned ? (
                      <Box className="CharSetup__medAntagBanned">
                        <Icon name="lock" mr={0.5} />
                        REVOKED
                      </Box>
                    ) : (
                      <Box
                        className={
                          "CharSetup__medAntagPrio" +
                          (isActive
                            ? " CharSetup__medAntagPrio--active"
                            : "")
                        }
                        style={
                          isActive
                            ? {
                                color: "#81c784",
                                borderColor: "#81c784",
                              }
                            : undefined
                        }
                        onClick={() =>
                          act("setAntagPriority", {
                            role: role.id,
                            priority: isActive ? "never" : "high",
                          })
                        }
                      >
                        <Icon
                          name={isActive ? "check" : "times"}
                          mr={0.25}
                        />
                        {isActive ? "CLEARED" : "DENIED"}
                      </Box>
                    )}
                  </Stack.Item>
                </Stack>
              </Box>
            );
          })}
        </Box>
      )}
    </>
  );
};

// --- Uplink sources sub-panel — Comms Config ---

const UplinkSubPanel = (props: {
  data: CharacterData;
  act: Function;
}) => {
  const { data, act } = props;
  const currentOrder = data.uplink_source_order || [];
  const available = (data.uplink_sources_available || []).filter(
    (src) => !currentOrder.includes(src.name)
  );

  return (
    <>
      {/* Comms header */}
      <Box className="CharSetup__medDocHeader CharSetup__medDocHeader--blue">
        <Stack align="center">
          <Stack.Item>
            <Icon
              name="satellite-dish"
              className="CharSetup__medDocIcon"
            />
          </Stack.Item>
          <Stack.Item grow>
            <Box className="CharSetup__medDocTitle">
              COVERT COMMUNICATIONS ARRAY
            </Box>
            <Box className="CharSetup__medDocSub">
              SYNDICATE NETWORK // PRIORITY ROUTING CONFIG
            </Box>
          </Stack.Item>
        </Stack>
      </Box>

      <Box className="CharSetup__medSection">
        <Box className="CharSetup__medSectionHead CharSetup__medSectionHead--blue">
          <Icon name="sort-amount-down" mr={0.5} />
          SOURCE PRIORITY ORDER
        </Box>

        <Box className="CharSetup__medCommsNote">
          <Icon name="info-circle" mr={0.5} />
          System attempts each source sequentially. First available
          connection is established.
        </Box>

        {currentOrder.map((name, index) => {
          const srcDef = (data.uplink_sources_available || []).find(
            (s) => s.name === name
          );
          return (
            <Box key={name} className="CharSetup__medCommsRow">
              <Stack align="center">
                <Stack.Item>
                  <Box className="CharSetup__medCommsIndex">
                    {String(index + 1).padStart(2, "0")}
                  </Box>
                </Stack.Item>
                <Stack.Item grow>
                  <Box className="CharSetup__medCommsName">{name}</Box>
                  {srcDef?.desc && (
                    <Box className="CharSetup__medCommsDesc">
                      {srcDef.desc}
                    </Box>
                  )}
                </Stack.Item>
                <Stack.Item>
                  <Box
                    className="CharSetup__medCommsBtn"
                    onClick={() =>
                      index > 0 &&
                      act("moveUplinkSource", {
                        name,
                        direction: "up",
                      })
                    }
                    style={{ opacity: index === 0 ? 0.3 : 1 }}
                  >
                    <Icon name="chevron-up" />
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Box
                    className="CharSetup__medCommsBtn"
                    onClick={() =>
                      index < currentOrder.length - 1 &&
                      act("moveUplinkSource", {
                        name,
                        direction: "down",
                      })
                    }
                    style={{
                      opacity:
                        index === currentOrder.length - 1 ? 0.3 : 1,
                    }}
                  >
                    <Icon name="chevron-down" />
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Box
                    className="CharSetup__medCommsBtn CharSetup__medCommsBtn--danger"
                    onClick={() =>
                      act("removeUplinkSource", { name })
                    }
                  >
                    <Icon name="times" />
                  </Box>
                </Stack.Item>
              </Stack>
            </Box>
          );
        })}

        {currentOrder.length === 0 && (
          <Box className="CharSetup__medCommsWarn">
            <Icon name="exclamation-triangle" mr={0.5} />
            NO UPLINK SOURCES CONFIGURED. YOU WILL NOT RECEIVE AN UPLINK.
          </Box>
        )}

        {available.length > 0 && (
          <Box mt={0.5}>
            <Dropdown
              fluid
              displayText="+ Add communications source..."
              options={available.map((s) => s.name)}
              onSelected={(val: string) =>
                act("addUplinkSource", { name: val })
              }
            />
          </Box>
        )}
      </Box>
    </>
  );
};

// ================================================================
// Background Panel — Sims-style dynamic layout
// ================================================================

const BACKGROUND_TABS = [
  { id: "identity", label: "Origins", icon: "globe-americas" },
  { id: "languages", label: "Languages", icon: "language" },
  { id: "records", label: "Records", icon: "file-medical" },
  { id: "flavor", label: "Description", icon: "feather-alt" },
  { id: "relations", label: "Relations", icon: "people-arrows" },
] as const;

type BackgroundTabId = (typeof BACKGROUND_TABS)[number]["id"];

const BackgroundPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const [tab, setTab] = useLocalState<BackgroundTabId>(
    context,
    "bgTab",
    "identity",
  );

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack wrap>
          {BACKGROUND_TABS.map((t) => (
            <Stack.Item key={t.id} grow basis="18%">
              <CsButton
                fluid
                selected={tab === t.id}
                onClick={() => setTab(t.id)}
                textAlign="center"
                icon={t.icon}
              >
                {t.label}
              </CsButton>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
      <Stack.Item mt={0.5}>
        <Divider />
      </Stack.Item>
      <Stack.Item grow basis={0} overflow="auto">
        {tab === "identity" && (
          <BackgroundOriginsSubPanel data={data} act={act} context={context} />
        )}
        {tab === "languages" && (
          <BackgroundLanguageSubPanel data={data} act={act} />
        )}
        {tab === "records" && (
          <BackgroundRecordsSubPanel data={data} act={act} context={context} />
        )}
        {tab === "flavor" && (
          <BackgroundFlavorSubPanel data={data} act={act} context={context} />
        )}
        {tab === "relations" && (
          <BackgroundRelationsSubPanel
            data={data}
            act={act}
            context={context}
          />
        )}
      </Stack.Item>
    </Stack>
  );
};

// --- Origins: big tappable cards for each background field ---

const ALIGNMENT_ICONS: Record<string, string> = {
  Loyal: "heart",
  Supportive: "thumbs-up",
  Neutral: "balance-scale",
  Skeptical: "question-circle",
  Opposed: "fist-raised",
};

const ALIGNMENT_COLORS: Record<string, string> = {
  Loyal: "green",
  Supportive: "teal",
  Neutral: "label",
  Skeptical: "orange",
  Opposed: "red",
};

const BackgroundOriginsSubPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const [showBankDetails, setShowBankDetails] = useLocalState(
    context,
    "showBankDetails",
    false,
  );

  return (
    <>
      {/* Spawn Point */}
      <Box bold mb={0.5}>
        <Icon name="map-marker-alt" mr={0.5} />
        Spawn Point
      </Box>
      <Box mb={1.5} className="CharSetup__card">
        <Stack align="center" px={0.5} py={0.25}>
          <Stack.Item grow>
            <Dropdown
              fluid
              selected={data.spawnpoint}
              options={data.spawnpoints}
              onSelected={(val) => act("setSpawnpoint", { spawnpoint: val })}
            />
          </Stack.Item>
        </Stack>
      </Box>

      {/* Company relation — big horizontal button row */}
      <Box bold mb={0.5}>
        <Icon name="building" mr={0.5} />
        {data.company_name} Relation
      </Box>
      <Stack mb={1.5}>
        {(data.company_alignments || []).map((alignment) => (
          <Stack.Item key={alignment} grow basis={0}>
            <CsButton
              fluid
              textAlign="center"
              selected={data.nanotrasen_relation === alignment}
              color={
                data.nanotrasen_relation === alignment
                  ? ALIGNMENT_COLORS[alignment]
                  : undefined
              }
              onClick={() => act("setRelation", { value: alignment })}
              icon={ALIGNMENT_ICONS[alignment] || "circle"}
            >
              {alignment}
            </CsButton>
          </Stack.Item>
        ))}
      </Stack>

      {/* Home System — full-width dropdown with globe icon */}
      <Box bold mb={0.5}>
        <Icon name="globe" mr={0.5} />
        Home System
      </Box>
      <Box mb={1.5} className="CharSetup__card">
        <Stack align="center">
          <Stack.Item grow>
            <Dropdown
              fluid
              selected={
                (data.home_systems || []).includes(data.home_system)
                  ? data.home_system
                  : data.home_system
              }
              displayText={
                <>
                  <Icon name="map-marker-alt" mr={1} />
                  {data.home_system}
                </>
              }
              options={data.home_systems || []}
              onSelected={(val: string) =>
                act("setHomeSystem", { value: val })
              }
            />
          </Stack.Item>
          {!(data.home_systems || []).includes(data.home_system) &&
            data.home_system !== "Unset" && (
              <Stack.Item>
                <Box color="good" fontSize="10px" italic>
                  Custom
                </Box>
              </Stack.Item>
            )}
        </Stack>
      </Box>

      {/* Faction/Background */}
      <Box bold mb={0.5}>
        <Icon name="flag" mr={0.5} />
        Faction
      </Box>
      <Box mb={1.5} className="CharSetup__card">
        <Dropdown
          fluid
          selected={
            (data.backgrounds || []).includes(data.background)
              ? data.background
              : data.background
          }
          displayText={
            <>
              <Icon name="shield-alt" mr={1} />
              {data.background}
            </>
          }
          options={data.backgrounds || []}
          onSelected={(val: string) => act("setBackground", { value: val })}
        />
      </Box>

      {/* Religion */}
      <Box bold mb={0.5}>
        <Icon name="pray" mr={0.5} />
        Religion
      </Box>
      <Box mb={1.5} className="CharSetup__card">
        <Dropdown
          fluid
          selected={
            (data.religions || []).includes(data.religion)
              ? data.religion
              : data.religion
          }
          displayText={
            <>
              <Icon name="star-of-life" mr={1} />
              {data.religion}
            </>
          }
          options={data.religions || []}
          onSelected={(val: string) => act("setReligion", { value: val })}
        />
      </Box>

      {/* Bank Account — collapsible card */}
      <Box
        className={classes([
          "CharSetup__card",
          "CharSetup__card--expandable",
          showBankDetails && "CharSetup__card--expanded",
        ])}
        onClick={() => setShowBankDetails(!showBankDetails)}
      >
        <Stack align="center">
          <Stack.Item>
            <Box inline mr={1} color="gold" style={{ fontSize: "120%" }}>
              <Icon name="university" />
            </Box>
          </Stack.Item>
          <Stack.Item grow>
            <Box bold>Bank Account</Box>
            <Box fontSize="11px" color="label">
              Security:{" "}
              {(data.bank_security_options || []).find(
                (o) => o.value === data.bank_security,
              )?.label || "Moderate"}{" "}
              | PIN: {data.bank_pin === 0 ? "Random" : data.bank_pin}
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Icon name={showBankDetails ? "chevron-up" : "chevron-down"} />
          </Stack.Item>
        </Stack>
      </Box>
      {showBankDetails && (
        <Box className="CharSetup__cardBody">
          <Box bold mb={0.5}>
            Security Level
          </Box>
          <Stack mb={1}>
            {(data.bank_security_options || []).map((opt) => (
              <Stack.Item key={opt.value} grow basis={0}>
                <CsButton
                  fluid
                  textAlign="center"
                  selected={data.bank_security === opt.value}
                  onClick={() =>
                    act("setBankSecurity", { value: opt.value })
                  }
                >
                  {opt.label}
                </CsButton>
              </Stack.Item>
            ))}
          </Stack>
          <Box bold mb={0.5}>
            PIN Code
          </Box>
          <Stack align="center">
            <Stack.Item>
              <NumberInput
                value={data.bank_pin || 0}
                minValue={0}
                maxValue={9999}
                step={1}
                width="80px"
                onChange={(e, val) => act("setBankPin", { value: val })}
              />
            </Stack.Item>
            <Stack.Item>
              <CsButton
                icon="dice"
                selected={data.bank_pin === 0}
                onClick={() => act("setBankPin", { value: 0 })}
              >
                Random
              </CsButton>
            </Stack.Item>
          </Stack>
        </Box>
      )}
    </>
  );
};

// --- Languages: visual badge system ---

const BackgroundLanguageSubPanel = (props: {
  data: CharacterData;
  act: Function;
}) => {
  const { data, act } = props;
  const langInfo = data.species_languages?.[data.species];
  const altLangs = data.alternate_languages || [];

  return (
    <>
      {/* Native languages as prominent badges */}
      <Box bold mb={0.5}>
        <Icon name="comment-dots" mr={0.5} />
        Native Languages
      </Box>
      <Stack wrap mb={1.5}>
        {langInfo?.native && (
          <Stack.Item>
            <Box
              inline
              mr={0.5}
              mb={0.5}
              className="CharSetup__pill CharSetup__pill--native"
            >
              <Icon name="star" mr={0.5} />
              {langInfo.native}
            </Box>
          </Stack.Item>
        )}
        {langInfo?.default &&
          langInfo.default !== langInfo.native && (
            <Stack.Item>
              <Box
                inline
                mr={0.5}
                mb={0.5}
                className="CharSetup__pill CharSetup__pill--secondary"
              >
                <Icon name="comment" mr={0.5} />
                {langInfo.default}
              </Box>
            </Stack.Item>
          )}
      </Stack>

      <Divider />

      {/* Secondary languages */}
      {langInfo && langInfo.max_alternates > 0 ? (
        <>
          <Stack align="center" mb={0.5}>
            <Stack.Item grow>
              <Box bold>
                <Icon name="plus-circle" mr={0.5} />
                Secondary Languages
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Box
                inline
                bold
                className={classes([
                  "CharSetup__pill",
                  "CharSetup__pill--count",
                  altLangs.length >= langInfo.max_alternates && "CharSetup__pill--countFull",
                ])}
              >
                {altLangs.length} / {langInfo.max_alternates}
              </Box>
            </Stack.Item>
          </Stack>

          {/* Active languages as removable pill badges */}
          <Stack wrap mb={1}>
            {altLangs.map((lang) => (
              <Stack.Item key={lang}>
                <Box
                  inline
                  mr={0.5}
                  mb={0.5}
                  className="CharSetup__pill CharSetup__pill--removable"
                >
                  {lang}
                  <CsButton
                    icon="times"
                    compact
                    ml={0.5}
                    onClick={() =>
                      act("removeLanguage", { language: lang })
                    }
                  />
                </Box>
              </Stack.Item>
            ))}
            {altLangs.length === 0 && (
              <Stack.Item>
                <Box color="label" italic fontSize="11px">
                  No secondary languages selected.
                </Box>
              </Stack.Item>
            )}
          </Stack>

          {/* Add language dropdown */}
          {altLangs.length < langInfo.max_alternates && (
            <Dropdown
              fluid
              displayText={
                <>
                  <Icon name="plus" mr={0.5} />
                  {"Learn a new language..."}
                </>
              }
              options={(langInfo.available || []).filter(
                (l) => !altLangs.includes(l),
              )}
              onSelected={(val: string) =>
                act("addLanguage", { language: val })
              }
            />
          )}
        </>
      ) : (
        <Box textAlign="center" mt={2} p={2} className="CharSetup__card">
          <Box mb={1} color="label" style={{ fontSize: "200%" }}>
            <Icon name="ban" />
          </Box>
          <Box color="label">
            This species cannot choose secondary languages.
          </Box>
        </Box>
      )}
    </>
  );
};

// --- Records: expandable card layout ---

const RECORD_DEFS = [
  {
    key: "medical",
    label: "Medical Records",
    icon: "heartbeat",
    color: "#ff6b6b",
  },
  {
    key: "general",
    label: "Employment Records",
    icon: "briefcase",
    color: "#4ecdc4",
  },
  {
    key: "security",
    label: "Security Records",
    icon: "shield-alt",
    color: "#ffe66d",
  },
  {
    key: "exploit",
    label: "Exploitable Info",
    icon: "user-secret",
    color: "#c792ea",
  },
  { key: "memory", label: "Memory", icon: "brain", color: "#82aaff" },
];

const RECORD_VALUES: Record<string, (d: CharacterData) => string> = {
  medical: (d) => d.med_record || "",
  general: (d) => d.gen_record || "",
  security: (d) => d.sec_record || "",
  exploit: (d) => d.exploit_record || "",
  memory: (d) => d.memory || "",
};

const BackgroundRecordsSubPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const [expandedRecord, setExpandedRecord] = useLocalState<string | null>(
    context,
    "expandedRecord",
    null,
  );

  if (data.records_banned) {
    return (
      <Box textAlign="center" mt={3} p={2}>
        <Icon name="ban" size={3} color="bad" />
        <Box mt={1} bold color="bad" fontSize="14px">
          Records Access Denied
        </Box>
        <Box color="label" mt={0.5}>
          You are banned from using character records.
        </Box>
      </Box>
    );
  }

  return (
    <>
      {RECORD_DEFS.map((rec) => {
        const value = RECORD_VALUES[rec.key](data);
        const isExpanded = expandedRecord === rec.key;
        const hasContent = !!value;

        return (
          <Box key={rec.key} mb={0.5}>
            {/* Card header */}
            <Box
              className={classes([
                "CharSetup__card",
                "CharSetup__card--expandable",
                isExpanded && "CharSetup__card--expanded",
              ])}
              onClick={() =>
                setExpandedRecord(isExpanded ? null : rec.key)
              }
            >
              <Stack align="center">
                <Stack.Item>
                  <Box inline className="CharSetup__cardIcon" color={rec.color}>
                    <Icon name={rec.icon} />
                  </Box>
                </Stack.Item>
                <Stack.Item grow ml={0.75}>
                  <Box bold>{rec.label}</Box>
                  {!isExpanded && (
                    <Box
                      className="CharSetup__cardPreview"
                      italic={!hasContent}
                    >
                      {hasContent
                        ? value.substring(0, 60) +
                          (value.length > 60 ? "..." : "")
                        : "Empty — click to write"}
                    </Box>
                  )}
                </Stack.Item>
                <Stack.Item>
                  {hasContent && (
                    <Box
                      inline
                      mr={0.5}
                      bold
                      className="CharSetup__pill CharSetup__pill--status"
                    >
                      Written
                    </Box>
                  )}
                  <Icon
                    name={isExpanded ? "chevron-up" : "chevron-down"}
                    color="label"
                  />
                </Stack.Item>
              </Stack>
            </Box>
            {/* Expanded editor */}
            {isExpanded && (
              <Box className="CharSetup__cardBody">
                <TextArea
                  fluid
                  height="100px"
                  value={value}
                  placeholder={`Write your ${rec.label.toLowerCase()}...`}
                  onChange={(e, val) =>
                    act("setRecord", { type: rec.key, text: val })
                  }
                />
              </Box>
            )}
          </Box>
        );
      })}
    </>
  );
};

// --- Flavor Text: body diagram with clickable parts ---

const FLAVOR_PARTS = [
  { key: "general", label: "General", icon: "user", desc: "Visible regardless of clothing" },
  { key: "head", label: "Head", icon: "hat-wizard", desc: "Head appearance" },
  { key: "face", label: "Face", icon: "laugh-beam", desc: "Facial features" },
  { key: "eyes", label: "Eyes", icon: "eye", desc: "Eye appearance" },
  { key: "torso", label: "Body", icon: "tshirt", desc: "Torso description" },
  { key: "arms", label: "Arms", icon: "hand-paper", desc: "Arm details" },
  { key: "hands", label: "Hands", icon: "hand-sparkles", desc: "Hand details" },
  { key: "legs", label: "Legs", icon: "running", desc: "Leg appearance" },
  { key: "feet", label: "Feet", icon: "shoe-prints", desc: "Feet details" },
  { key: "action", label: "Pose", icon: "theater-masks", desc: "Default action or pose" },
];

const BackgroundFlavorSubPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const [flavorMode, setFlavorMode] = useLocalState<"human" | "robot">(
    context,
    "flavorMode",
    "human",
  );
  const [activePart, setActivePart] = useLocalState<string | null>(
    context,
    "activePart",
    null,
  );

  return (
    <>
      {/* Mode toggle — big segmented control */}
      <Stack mb={1}>
        <Stack.Item grow basis={0}>
          <CsButton
            fluid
            textAlign="center"
            selected={flavorMode === "human"}
            icon="user"
            onClick={() => {
              setFlavorMode("human");
              setActivePart(null);
            }}
          >
            Character
          </CsButton>
        </Stack.Item>
        <Stack.Item grow basis={0}>
          <CsButton
            fluid
            textAlign="center"
            selected={flavorMode === "robot"}
            icon="robot"
            onClick={() => {
              setFlavorMode("robot");
              setActivePart(null);
            }}
          >
            Robot
          </CsButton>
        </Stack.Item>
      </Stack>

      {flavorMode === "human" && (
        <>
          {/* Body part grid — 2 columns of tappable tiles */}
          <Box className="CharSetup__bodyPartGrid">
            {FLAVOR_PARTS.map((part) => {
              const value = data.flavor_texts?.[part.key] || "";
              const isActive = activePart === part.key;
              const hasText = !!value;

              return (
                <Box
                  key={part.key}
                  className={classes([
                    "CharSetup__bodyPart",
                    isActive && "CharSetup__bodyPart--active",
                    hasText && "CharSetup__bodyPart--filled",
                  ])}
                  onClick={() =>
                    setActivePart(isActive ? null : part.key)
                  }
                >
                    <Stack align="center">
                      <Stack.Item>
                        <Icon
                          name={part.icon}
                          color={hasText ? "good" : "label"}
                        />
                      </Stack.Item>
                      <Stack.Item grow ml={0.5}>
                        <Box bold fontSize="11px">
                          {part.label}
                        </Box>
                      </Stack.Item>
                      {hasText && (
                        <Stack.Item>
                          <Icon name="check" color="good" size={0.8} />
                        </Stack.Item>
                      )}
                    </Stack>
                  </Box>
              );
            })}
          </Box>

          {/* Editor for active part */}
          {activePart && (
            <Box mt={0.5} className="CharSetup__cardBody">
              <Box bold mb={0.5}>
                <Icon
                  name={
                    FLAVOR_PARTS.find((p) => p.key === activePart)
                      ?.icon || "pen"
                  }
                  mr={0.5}
                />
                {FLAVOR_PARTS.find((p) => p.key === activePart)?.label}
                <Box inline ml={1} fontSize="10px" color="label">
                  {FLAVOR_PARTS.find((p) => p.key === activePart)?.desc}
                </Box>
              </Box>
              <TextArea
                fluid
                height="80px"
                value={data.flavor_texts?.[activePart] || ""}
                placeholder="Describe this area..."
                onChange={(e, val) =>
                  act("setFlavorText", { part: activePart, text: val })
                }
              />
            </Box>
          )}
        </>
      )}

      {flavorMode === "robot" && (
        <>
          {["Default", ...(data.robot_module_types || [])].map((mod) => {
            const value = data.flavour_texts_robot?.[mod] || "";
            const isActive = activePart === `robot_${mod}`;
            const hasText = !!value;

            return (
              <Box key={mod} mb={0.5}>
                <Box
                  className={classes([
                    "CharSetup__card",
                    "CharSetup__card--expandable",
                    isActive && "CharSetup__card--expanded",
                    hasText && !isActive && "CharSetup__bodyPart--filled",
                  ])}
                  onClick={() =>
                    setActivePart(isActive ? null : `robot_${mod}`)
                  }
                >
                  <Stack align="center">
                    <Stack.Item>
                      <Icon
                        name={mod === "Default" ? "cog" : "microchip"}
                        color={hasText ? "good" : "label"}
                      />
                    </Stack.Item>
                    <Stack.Item grow ml={0.5}>
                      <Box bold fontSize="12px">
                        {mod}
                      </Box>
                    </Stack.Item>
                    {hasText && (
                      <Stack.Item>
                        <Icon name="check" color="good" size={0.8} />
                      </Stack.Item>
                    )}
                    <Stack.Item>
                      <Icon
                        name={isActive ? "chevron-up" : "chevron-down"}
                        color="label"
                      />
                    </Stack.Item>
                  </Stack>
                </Box>
                {isActive && (
                  <Box className="CharSetup__cardBody">
                    <TextArea
                      fluid
                      height="70px"
                      value={value}
                      placeholder={
                        mod === "Default"
                          ? "Default flavor text for all modules..."
                          : `Flavor text for ${mod} module...`
                      }
                      onChange={(e, val) =>
                        act("setRobotFlavorText", {
                          module: mod,
                          text: val,
                        })
                      }
                    />
                  </Box>
                )}
              </Box>
            );
          })}
        </>
      )}
    </>
  );
};

// --- Relations: big toggle cards ---

const RELATION_ICONS: Record<string, string> = {
  Friend: "handshake",
  "Childhood Friend": "child",
  Enemy: "angry",
  Crossed: "bolt",
  "Was Crossed": "sad-tear",
  Rival: "trophy",
  Ex: "heart-broken",
  "Served Together": "medal",
};

const BackgroundRelationsSubPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const [editingInfo, setEditingInfo] = useLocalState<string | null>(
    context,
    "editingRelInfo",
    null,
  );
  const relations = data.relations || [];
  const relationsInfo = data.relations_info || {};
  const relationTypes = data.relation_types || [];

  return (
    <>
      <Box
        mb={1}
        fontSize="11px"
        color="label"
        className="CharSetup__card CharSetup__card--info CharSetup__card--accentLeft"
        style={{ "--cs-card-accent": "rgba(100,149,237,0.5)" }}
      >
        <Icon name="info-circle" mr={0.5} />
        Characters with enabled relations are paired randomly after spawn. You
        can terminate relations on first viewing, then they become permanent.
      </Box>

      {/* General info card */}
      <Box mb={1} className="CharSetup__card">
        <Stack align="center" mb={0.5}>
          <Stack.Item>
            <Icon name="id-card" color="label" mr={0.5} />
          </Stack.Item>
          <Stack.Item grow>
            <Box bold>Public Profile</Box>
            <Box fontSize="10px" color="label">
              What all connections know about you
            </Box>
          </Stack.Item>
          <Stack.Item>
            <CsButton
              icon={editingInfo === "general" ? "check" : "pen"}
              compact
              onClick={() =>
                setEditingInfo(editingInfo === "general" ? null : "general")
              }
            />
          </Stack.Item>
        </Stack>
        {editingInfo === "general" ? (
          <TextArea
            fluid
            height="50px"
            value={relationsInfo["general"] || ""}
            placeholder="What would others know about you?"
            onChange={(e, val) =>
              act("setRelationInfo", { name: "general", text: val })
            }
          />
        ) : (
          <Box
            italic={!relationsInfo["general"]}
            fontSize="11px"
            color={relationsInfo["general"] ? "default" : "label"}
          >
            {relationsInfo["general"] || "Nothing specific."}
          </Box>
        )}
      </Box>

      <Divider />

      {/* Relation type cards */}
      {relationTypes.map((rel) => {
        const isEnabled = relations.includes(rel.name);
        const isEditingThis = editingInfo === rel.name;
        const iconName = RELATION_ICONS[rel.name] || "user-friends";

        return (
          <Box
            key={rel.name}
            mb={0.75}
            className={classes([
              "CharSetup__card",
              "CharSetup__relation",
              isEnabled && "CharSetup__card--enabled",
            ])}
          >
            {/* Toggle row */}
            <Stack align="center" mb={0.25}>
              <Stack.Item>
                <Icon
                  name={iconName}
                  size={1.3}
                  color={isEnabled ? "good" : "label"}
                />
              </Stack.Item>
              <Stack.Item grow ml={0.75}>
                <Box bold>{rel.name}</Box>
                <Box fontSize="10px" color="label" italic>
                  {rel.desc}
                </Box>
              </Stack.Item>
              <Stack.Item>
                <CsButton
                  width="55px"
                  textAlign="center"
                  selected={isEnabled}
                  color={isEnabled ? "good" : undefined}
                  onClick={() =>
                    act("toggleRelation", { name: rel.name })
                  }
                >
                  {isEnabled ? "ON" : "OFF"}
                </CsButton>
              </Stack.Item>
            </Stack>

            {/* Info editing (only when enabled) */}
            {isEnabled && (
              <Box mt={0.5}>
                <Stack align="center">
                  <Stack.Item grow>
                    <Box fontSize="10px" color="label">
                      <Icon name="comment-dots" mr={0.25} />
                      {" Personal note for this connection:"}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <CsButton
                      icon={isEditingThis ? "check" : "pen"}
                      compact
                      onClick={() =>
                        setEditingInfo(
                          isEditingThis ? null : rel.name,
                        )
                      }
                    />
                  </Stack.Item>
                </Stack>
                {isEditingThis ? (
                  <TextArea
                    fluid
                    height="40px"
                    value={relationsInfo[rel.name] || ""}
                    placeholder="What should they know?"
                    onChange={(e, val) =>
                      act("setRelationInfo", {
                        name: rel.name,
                        text: val,
                      })
                    }
                  />
                ) : (
                  <Box
                    italic={!relationsInfo[rel.name]}
                    fontSize="10px"
                    color={relationsInfo[rel.name] ? "default" : "label"}
                    mt={0.25}
                  >
                    {relationsInfo[rel.name] || "Nothing specific."}
                  </Box>
                )}
              </Box>
            )}
          </Box>
        );
      })}
    </>
  );
};

// ================================================================
// Settings Panel — dynamic grouped layout
// ================================================================

const PREF_CATEGORY_META: Record<
  string,
  { icon: string; color: string }
> = {
  UI: { icon: "desktop", color: "#82aaff" },
  Graphics: { icon: "paint-brush", color: "#c792ea" },
  Audio: { icon: "volume-up", color: "#ff6b6b" },
  TGUI: { icon: "window-maximize", color: "#4ecdc4" },
  Chat: { icon: "comments", color: "#ffe66d" },
  Control: { icon: "gamepad", color: "#f78c6c" },
  Ghost: { icon: "ghost", color: "#b2ccd6" },
  Misc: { icon: "cogs", color: "#c3e88d" },
  Staff: { icon: "user-shield", color: "#ffcb6b" },
};

// Display order for preference categories
const PREF_CATEGORY_ORDER = [
  "UI",
  "Graphics",
  "Audio",
  "TGUI",
  "Chat",
  "Control",
  "Ghost",
  "Misc",
  "Staff",
];

const SettingsPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const [settingsMode, setSettingsMode] = useLocalState<
    "prefs" | "keys"
  >(context, "settingsMode", "prefs");

  return (
    <Stack vertical fill>
      {/* Big segmented mode toggle */}
      <Stack.Item>
        <Stack>
          <Stack.Item grow basis={0}>
            <CsButton
              fluid
              textAlign="center"
              selected={settingsMode === "prefs"}
              icon="sliders-h"
              onClick={() => setSettingsMode("prefs")}
            >
              Preferences
            </CsButton>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <CsButton
              fluid
              textAlign="center"
              selected={settingsMode === "keys"}
              icon="keyboard"
              onClick={() => setSettingsMode("keys")}
            >
              Keybindings
            </CsButton>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item mt={0.5}>
        <Divider />
      </Stack.Item>
      <Stack.Item grow basis={0} overflow="auto">
        {settingsMode === "prefs" && (
          <PreferencesSubPanel data={data} act={act} context={context} />
        )}
        {settingsMode === "keys" && (
          <KeybindingsSubPanel data={data} act={act} context={context} />
        )}
      </Stack.Item>
    </Stack>
  );
};

// --- Preferences: collapsible category cards with inline toggles ---

const PreferencesSubPanel = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;
  const categories = data.client_preference_categories || {};
  const values = data.preference_values || {};
  const [expandedCat, setExpandedCat] = useLocalState<string | null>(
    context,
    "prefExpandedCat",
    null,
  );

  // Sort categories by display order
  const sortedCats = PREF_CATEGORY_ORDER.filter((c) => c in categories);
  for (const cat of Object.keys(categories)) {
    if (!sortedCats.includes(cat)) {
      sortedCats.push(cat);
    }
  }

  return (
    <>
      {sortedCats.filter((catName) => (categories[catName] || []).length > 0).map((catName) => {
        const prefs = categories[catName] || [];
        const meta = PREF_CATEGORY_META[catName] || {
          icon: "cog",
          color: "#999",
        };
        const isExpanded = expandedCat === catName || expandedCat === null;

        return (
          <Box key={catName} mb={0.5}>
            {/* Category header */}
            <Box
              className={classes([
                "CharSetup__card",
                "CharSetup__card--expandable",
                "CharSetup__card--accentLeft",
                isExpanded && "CharSetup__card--expanded",
              ])}
              style={{ "--cs-card-accent": meta.color }}
              onClick={() =>
                setExpandedCat(isExpanded && expandedCat !== null ? null : catName)
              }
            >
              <Stack align="center">
                <Stack.Item>
                  <Box inline className="CharSetup__cardIcon" color={meta.color}>
                    <Icon name={meta.icon} />
                  </Box>
                </Stack.Item>
                <Stack.Item grow ml={0.5}>
                  <Box bold>{catName}</Box>
                </Stack.Item>
                <Stack.Item>
                  <Box
                    inline
                    fontSize="10px"
                    color="label"
                    mr={0.5}
                  >
                    {prefs.length} settings
                  </Box>
                  <Icon
                    name={isExpanded ? "chevron-up" : "chevron-down"}
                    color="label"
                  />
                </Stack.Item>
              </Stack>
            </Box>

            {/* Preference rows */}
            {isExpanded && (
              <Box className="CharSetup__cardBody">
                {prefs.map((pref, i) => (
                  <Box
                    key={pref.key}
                    className={classes([
                      "CharSetup__prefRow",
                      i % 2 !== 0 && "CharSetup__prefRow--alt",
                    ])}
                  >
                    <Box bold fontSize="11px" mb={0.3}>
                      {pref.description}
                    </Box>
                    <Stack wrap>
                      {(pref.options || []).map((option) => {
                        const isSelected =
                          values[pref.key] === option;
                        return (
                          <Stack.Item key={option} mr={0.25} mb={0.25}>
                            <CsButton
                              selected={isSelected}
                              compact
                              onClick={() =>
                                act("setClientPreference", {
                                  key: pref.key,
                                  value: option,
                                })
                              }
                            >
                              {option}
                            </CsButton>
                          </Stack.Item>
                        );
                      })}
                    </Stack>
                  </Box>
                ))}
              </Box>
            )}
          </Box>
        );
      })}
    </>
  );
};

// --- Key capture: translate JS keyboard events to BYOND key format ---

const JS_TO_BYOND_KEY: Record<string, string> = {
  ArrowUp: "North",
  ArrowDown: "South",
  ArrowLeft: "West",
  ArrowRight: "East",
  Insert: "Insert",
  Home: "Northwest",
  PageUp: "Northeast",
  Delete: "Delete",
  End: "Southwest",
  PageDown: "Southeast",
  " ": "Space",
  Enter: "Enter",
  Escape: "Escape",
  Tab: "Tab",
  Backspace: "Backspace",
  F1: "F1", F2: "F2", F3: "F3", F4: "F4",
  F5: "F5", F6: "F6", F7: "F7", F8: "F8",
  F9: "F9", F10: "F10", F11: "F11", F12: "F12",
};

const jsKeyToBYOND = (e: KeyboardEvent): string | null => {
  // Ignore bare modifier presses
  if (e.key === "Alt" || e.key === "Control" || e.key === "Shift") {
    return null;
  }

  let key = JS_TO_BYOND_KEY[e.key];
  if (!key) {
    // Single character keys — uppercase
    if (e.key.length === 1) {
      key = e.key.toUpperCase();
    } else {
      return null;
    }
  }

  const alt = e.altKey ? "Alt" : "";
  const ctrl = e.ctrlKey ? "Ctrl" : "";
  const shift = e.shiftKey ? "Shift" : "";

  return `${alt}${ctrl}${shift}${key}`;
};

// Display-friendly names for BYOND key codes
const BYOND_KEY_DISPLAY: Record<string, string> = {
  North: "Up", South: "Down", East: "Right", West: "Left",
  Northwest: "Home", Northeast: "PageUp",
  Southwest: "End", Southeast: "PageDown",
};

const displayKey = (key: string): string => {
  // Replace BYOND direction names with friendly names anywhere in the string
  let result = key;
  for (const [byond, display] of Object.entries(BYOND_KEY_DISPLAY)) {
    result = result.replace(byond, display);
  }
  return result;
};

// --- Keybindings: grouped cards with key badges ---

const KB_CATEGORY_ORDER = [
  "MOVEMENT",
  "COMMUNICATION",
  "CARBON",
  "HUMAN",
  "ROBOT",
  "CLIENT",
  "ADMIN",
  "MISC",
];

const KB_CATEGORY_ICONS: Record<string, string> = {
  MOVEMENT: "arrows-alt",
  COMMUNICATION: "comments",
  CARBON: "heartbeat",
  HUMAN: "user",
  ROBOT: "robot",
  CLIENT: "desktop",
  ADMIN: "user-shield",
  MISC: "puzzle-piece",
};

class KeybindingsSubPanel extends Component<{
  data: CharacterData;
  act: Function;
  context: any;
}, {
  expandedKbCat: string | null;
  capturingBinding: string | null;
  capturingOldKey: string | null;
}> {
  keyHandler: ((e: KeyboardEvent) => void) | null;

  constructor(props) {
    super(props);
    this.state = {
      expandedKbCat: null,
      capturingBinding: null,
      capturingOldKey: null,
    };
    this.keyHandler = null;
  }

  componentWillUnmount() {
    this.stopCapture();
  }

  startCapture(bindingName: string, oldKey: string | null) {
    this.stopCapture();

    this.keyHandler = (e: KeyboardEvent) => {
      e.preventDefault();
      e.stopPropagation();

      if (e.key === "Escape") {
        this.stopCapture();
        return;
      }

      // Backspace/Delete clears the binding being edited
      if ((e.key === "Backspace" || e.key === "Delete") && oldKey) {
        this.props.act("clearKeybinding", {
          binding: bindingName,
          old_key: oldKey,
        });
        this.stopCapture();
        return;
      }

      const byondKey = jsKeyToBYOND(e);
      if (!byondKey) return;

      this.props.act("setKeybinding", {
        binding: bindingName,
        key: byondKey,
        old_key: oldKey || "",
      });
      this.stopCapture();
    };

    document.addEventListener("keydown", this.keyHandler, true);
    this.setState({ capturingBinding: bindingName, capturingOldKey: oldKey });
  }

  stopCapture() {
    if (this.keyHandler) {
      document.removeEventListener("keydown", this.keyHandler, true);
      this.keyHandler = null;
    }
    this.setState({ capturingBinding: null, capturingOldKey: null });
  }

  render() {
    const { data, act } = this.props;
    const { expandedKbCat, capturingBinding } = this.state;
    const kbCategories = data.keybinding_categories || {};
    const userBinds = data.user_keybindings || {};

    // Sort categories
    const sortedCats = KB_CATEGORY_ORDER.filter((c) => c in kbCategories);
    for (const cat of Object.keys(kbCategories)) {
      if (!sortedCats.includes(cat)) {
        sortedCats.push(cat);
      }
    }

    const isCapturing = capturingBinding !== null;

    return (
      <>
        {/* Header with reset all */}
        <Stack align="center" mb={1}>
          <Stack.Item grow>
            <Box bold>
              <Icon name="keyboard" mr={0.5} />
              Keybindings
            </Box>
          </Stack.Item>
          <Stack.Item>
            <CsButton
              icon="undo"
              color="bad"
              compact
              onClick={() => act("resetAllKeybindings")}
            >
              Reset All
            </CsButton>
          </Stack.Item>
        </Stack>

        {sortedCats.filter((catName) => (kbCategories[catName] || []).length > 0).map((catName) => {

          const bindings = kbCategories[catName] || [];
          const isExpanded = expandedKbCat === catName;
          const iconName = KB_CATEGORY_ICONS[catName] || "cog";

          return (
            <Box key={catName} mb={0.5}>
              {/* Category header */}
              <Box
                className={classes([
                  "CharSetup__card",
                  "CharSetup__card--expandable",
                  isExpanded && "CharSetup__card--expanded",
                ])}
                onClick={() =>
                  this.setState({ expandedKbCat: isExpanded ? null : catName })
                }
              >
                <Stack align="center">
                  <Stack.Item>
                    <Icon name={iconName} color="label" />
                  </Stack.Item>
                  <Stack.Item grow ml={0.5}>
                    <Box bold>
                      {catName.charAt(0) +
                        catName.slice(1).toLowerCase()}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Box inline fontSize="10px" color="label" mr={0.5}>
                      {bindings.length} bindings
                    </Box>
                    <Icon
                      name={isExpanded ? "chevron-up" : "chevron-down"}
                      color="label"
                    />
                  </Stack.Item>
                </Stack>
              </Box>

              {/* Binding rows */}
              {isExpanded && (
                <Box className="CharSetup__cardBody">
                  {bindings.map((kb, i) => {
                    const keys = userBinds[kb.name] || [];
                    const activeKeys = keys.filter(
                      (k) => k !== "None",
                    );
                    const isDefault =
                      JSON.stringify([...keys].sort()) ===
                      JSON.stringify(
                        [...(kb.default_keys || [])].sort(),
                      );
                    const isThisCapturing = capturingBinding === kb.name;

                    return (
                      <Box
                        key={kb.name}
                        className={classes([
                          "CharSetup__prefRow",
                          i % 2 !== 0 && "CharSetup__prefRow--alt",
                        ])}
                      >
                        <Stack align="center">
                          <Stack.Item grow basis={0}>
                            <Box bold fontSize="11px">
                              {kb.full_name}
                            </Box>
                            {kb.description && (
                              <Box fontSize="9px" color="label">
                                {kb.description}
                              </Box>
                            )}
                          </Stack.Item>
                          <Stack.Item>
                            <Stack align="center">
                              {isThisCapturing ? (
                                <Stack.Item>
                                  <Box
                                    inline
                                    className="CharSetup__keyBadge CharSetup__keyBadge--capturing"
                                  >
                                    Press a key...
                                  </Box>
                                </Stack.Item>
                              ) : (
                                <>
                                  {activeKeys.length > 0 ? (
                                    activeKeys.map((key, ki) => (
                                      <Stack.Item key={ki}>
                                        <Box inline className="CharSetup__keyBadgeWrap">
                                          <Box
                                            inline
                                            className="CharSetup__keyBadge"
                                            style={{ cursor: "pointer" }}
                                            onClick={() => this.startCapture(kb.name, key)}
                                          >
                                            {displayKey(key)}
                                          </Box>
                                          <Box
                                            inline
                                            className="CharSetup__keyBadgeRemove"
                                            onClick={(e) => {
                                              e.stopPropagation();
                                              act("clearKeybinding", {
                                                binding: kb.name,
                                                old_key: key,
                                              });
                                            }}
                                          >
                                            <Icon name="times" />
                                          </Box>
                                        </Box>
                                      </Stack.Item>
                                    ))
                                  ) : (
                                    <Stack.Item>
                                      <Box
                                        inline
                                        className="CharSetup__keyBadge CharSetup__keyBadge--unbound"
                                      >
                                        Unbound
                                      </Box>
                                    </Stack.Item>
                                  )}
                                </>
                              )}
                              <Stack.Item ml={0.5}>
                                <CsButton
                                  icon="plus"
                                  compact
                                  disabled={isCapturing}
                                  onClick={() => this.startCapture(kb.name, null)}
                                />
                              </Stack.Item>
                              <Stack.Item>
                                <CsButton
                                  icon="undo"
                                  compact
                                  disabled={isDefault}
                                  onClick={() =>
                                    act("resetKeybinding", {
                                      binding: kb.name,
                                    })
                                  }
                                />
                              </Stack.Item>
                            </Stack>
                          </Stack.Item>
                        </Stack>
                      </Box>
                    );
                  })}
                </Box>
              )}
            </Box>
          );
        })}
      </>
    );
  }
}
