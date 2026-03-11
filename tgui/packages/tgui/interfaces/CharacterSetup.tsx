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
  Button,
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
  Tooltip,
} from "../components";
import { Window } from "../layouts";
import {
  CharacterRenderConfig,
  getCompositor,
} from "../spriteCompositor";
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

// UI theme preview images
import uiPreviewBg from "../assets/settings/preview.png";
import uiPreviewItems from "../assets/settings/items.png";
import uiGoon from "../assets/settings/ui-goon.png";
import uiMidnight from "../assets/settings/ui-midnight.png";
import uiMinimalist from "../assets/settings/ui-minimalist.png";
import uiOld from "../assets/settings/ui-old.png";
import uiOldNoborder from "../assets/settings/ui-old-noborder.png";
import uiOrange from "../assets/settings/ui-orange.png";
import uiWhite from "../assets/settings/ui-white.png";

// ================================================================
// SearchDropdown — combined search input + dropdown list
// ================================================================

interface SearchDropdownProps {
  selected: string;
  options: string[];
  onSelected: (val: string) => void;
  placeholder?: string;
  fluid?: boolean;
}

class SearchDropdown extends Component<SearchDropdownProps, {
  query: string;
  open: boolean;
}> {
  private scrollRef: HTMLDivElement | null = null;

  constructor(props) {
    super(props);
    this.state = { query: "", open: false };
  }

  render() {
    const { selected, options, onSelected, placeholder, fluid } = this.props;
    const { query, open } = this.state;
    const filtered = query
      ? options.filter((o) => o.toLowerCase().includes(query.toLowerCase()))
      : options;

    return (
      <Box
        className="SearchDropdown"
        style={{ width: fluid ? "100%" : undefined }}
      >
        <Box className="SearchDropdown__inputWrap">
          <input
            className="SearchDropdown__input"
            placeholder={open ? (placeholder || "Search...") : selected}
            value={query}
            onInput={(e: any) => this.setState({ query: e.target.value, open: true })}
            onClick={() => this.setState({ open: true })}
            onFocusin={() => this.setState({ open: true })}
            onFocusout={() => {
              // Delay so click on option fires first
              setTimeout(() => this.setState({ open: false, query: "" }), 150);
            }}
          />
          <Icon
            name="chevron-down"
            className="SearchDropdown__chevron"
          />
        </Box>
        {open && filtered.length > 0 && (
          <Box className="SearchDropdown__list"
            ref={(el) => {
              if (el && el !== this.scrollRef) {
                this.scrollRef = el;
                // Scroll selected into view
                const idx = filtered.indexOf(selected);
                if (idx > 0) {
                  const child = el.children[idx] as HTMLElement;
                  if (child) {
                    child.scrollIntoView({ block: "center" });
                  }
                }
              }
            }}
          >
            {filtered.map((opt) => (
              <Box
                key={opt}
                className={classes([
                  "SearchDropdown__option",
                  opt === selected && "SearchDropdown__option--selected",
                ])}
                onMousedown={(e) => {
                  e.preventDefault();
                  onSelected(opt);
                  this.setState({ open: false, query: "" });
                }}
              >
                {opt}
              </Box>
            ))}
          </Box>
        )}
      </Box>
    );
  }
}

const UI_THEME_IMAGE: Record<string, string> = {
  "Goon": uiGoon,
  "Midnight": uiMidnight,
  "Orange": uiOrange,
  "Old": uiOld,
  "White": uiWhite,
  "Old-noborder": uiOldNoborder,
  "Minimalist": uiMinimalist,
};

// Map departments → department head stamp (always use the head's stamp)
const DEPT_STAMP: Record<string, string> = {
  "Command": stampCap,
  "Security": stampHos,
  "Medical": stampCmo,
  "Engineering": stampCe,
  "Science": stampRd,
  "Cargo": stampCargo,
  "Civilian": stampHop,
  "Provisioning": stampHop,
  "Supply": stampCargo,
};

const getStampForJob = (job: JobInfo | null): string => {
  if (!job) return stampCent;
  return DEPT_STAMP[job.department] || stampOk;
};

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
  icobase: string;
  hair_key: string;
}

interface HairStyle {
  name: string;
  icon_state: string;
  gender: string;
  species_allowed: string[];
  has_secondary: boolean;
}

interface FacialHairStyle {
  name: string;
  icon_state: string;
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
  icon: string;
  icon_state: string;
  body_parts: string[];
  draw_target: number; // 0=SKIN, 1=HAIR, 2=HEAD
}

interface UnderwearCategory {
  name: string;
  items: string[];
  colorable: string[];
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
  deptEntries?: { label: string; subtype: string }[];
}

interface GearItem {
  name: string;
  hash: string;
  icon: string | null;
  iconState: string | null;
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
  tweakedIconState: string | null;
  tweakedColor: string | null;
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
  icon: string;
  species_cannot_use: string[];
  restricted_to: string[];
  applies_to_part: string[];
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
  minimum_character_age: number;
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

// Slot preview data — raw appearance fields for client-side rendering
interface SlotAppearanceData {
  species: string;
  gender: string;
  body: string;
  h_style: string;
  f_style: string;
  hair_color: string;
  s_hair_color: string;
  facial_color: string;
  skin_color: string;
  eye_color: string;
  s_tone: number;
  icobase: string | null;
  hair_key: string;
  appearance_flags: number;
}

interface SlotPreviewData {
  slot: number;
  name: string;
  appearance: SlotAppearanceData | null;
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
  // Render data (for client-side sprite compositor)
  hair_icons: Record<string, Record<string, string>>;
  facial_hair_icons: Record<string, Record<string, string>>;
  body_build_render: Record<string, { index: string; clothing_icons: Record<string, string> }>;
  // Settings static
  client_preference_categories: Record<string, ClientPreferenceDef[]>;
  keybinding_categories: Record<string, KeybindingDef[]>;
  // Dynamic data
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
  all_underwear_color: Record<string, string>;
  underwear_render: { state: string; dmiFile: string; color: string | null }[];
  equipment_render: { dmiFile: string; state: string; color: string | null; layer: number }[];
  hide_hair: boolean;
  hide_facial_hair: boolean;
  backpack: string;
  backpack_tweaks?: { tweakIndex: number; options: string[]; current: string }[];
  equip_preview_mob: number;
  bgstate: string;
  can_undo: boolean;
  default_slot: number;
  is_guest: boolean;
  load_failed: string | null;
  character_slots_info: { slot: number; name: string }[];
  slot_previews?: SlotPreviewData[];
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
  // UI theme
  ui_themes: string[];
  ui_style: string;
  ui_style_color: string;
  ui_style_alpha: number;
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
// Sprite Compositor — build render config from character data
// ================================================================

// Marking draw target values (mirrored from DM)
const MARKING_TARGET_SKIN = 0;
const MARKING_TARGET_HAIR = 1;

/** Convert a hex color like "#8e2929" to rgba with given alpha */
function hexToRgba(hex: string, alpha: number): string {
  const r = parseInt(hex.slice(1, 3), 16) || 0;
  const g = parseInt(hex.slice(3, 5), 16) || 0;
  const b = parseInt(hex.slice(5, 7), 16) || 0;
  return `rgba(${r},${g},${b},${alpha})`;
}

/** Resolve hair/facial DMI files and style objects from shared build+species data */
function resolveHairInfo(
  data: CharacterData,
  bodyName: string,
  hairKey: string,
  hStyle: string,
  fStyle: string,
) {
  const buildIndex = data.body_build_render?.[bodyName]?.index || "";
  // "slim" builds use a separate hair icon set
  const isSlim = buildIndex.indexOf("_slim") !== -1;

  let hairDmiFile = data.hair_icons?.["default"]?.[hairKey] || "";
  if (isSlim && data.hair_icons?.["slim"]?.[hairKey]) {
    hairDmiFile = data.hair_icons["slim"][hairKey];
  }

  let facialDmiFile = data.facial_hair_icons?.["default"]?.[hairKey] || "";
  if (isSlim && data.facial_hair_icons?.["slim"]?.[hairKey]) {
    facialDmiFile = data.facial_hair_icons["slim"][hairKey];
  }

  const hairStyle = data.hair_styles?.find((h) => h.name === hStyle);
  const facialStyle = data.facial_hair_styles?.find((f) => f.name === fStyle);

  return { buildIndex, hairDmiFile, facialDmiFile, hairStyle, facialStyle };
}

/** Build a CharacterRenderConfig from the current preference data */
function buildRenderConfig(data: CharacterData): CharacterRenderConfig | null {
  const speciesInfo = getSpeciesInfo(data.species_list, data.species);
  if (!speciesInfo) return null;

  const { buildIndex, hairDmiFile, facialDmiFile, hairStyle, facialStyle } =
    resolveHairInfo(data, data.body || "Default", speciesInfo.hair_key, data.h_style, data.f_style);

  const underwear = data.underwear_render?.map(uw => ({
    state: uw.state,
    dmiFile: uw.dmiFile,
    color: uw.color,
  }));

  const clothing = data.equipment_render?.map(eq => ({
    state: eq.state,
    dmiFile: eq.dmiFile,
    color: eq.color,
    layer: eq.layer,
  }));

  const robolimbIcons: Record<string, string> = {};
  if (data.robolimb_brands) {
    for (const brand of data.robolimb_brands) {
      if (brand.icon) robolimbIcons[brand.company] = brand.icon;
    }
  }

  // Expand skin markings to per-organ entries; hair markings are drawn masked to hair shape
  const markings: { icon: string; iconState: string; organTag: string; color: string }[] = [];
  const hairMarkings: { icon: string; iconState: string; color: string }[] = [];
  if (data.body_markings) {
    for (const m of data.body_markings) {
      if (!m.icon || !m.icon_state) continue;
      if (m.draw_target === MARKING_TARGET_HAIR) {
        hairMarkings.push({ icon: m.icon, iconState: m.icon_state, color: m.color });
      } else if (m.draw_target === MARKING_TARGET_SKIN && m.body_parts) {
        for (const organTag of m.body_parts) {
          markings.push({ icon: m.icon, iconState: `${m.icon_state}-${organTag}`, organTag, color: m.color });
        }
      }
    }
  }

  return {
    species: data.species,
    gender: data.gender,
    bodyBuild: buildIndex,
    direction: data.preview_dir,
    skinTone: data.s_tone || 0,
    skinColor: (speciesInfo.appearance_flags & HAS_SKIN_COLOR) ? data.skin_color : null,
    hairStyle: hairStyle?.icon_state || "",
    hairColor: data.hair_color,
    secondaryHairColor: hairStyle?.has_secondary ? data.s_hair_color : null,
    hairDmiFile,
    facialStyle: facialStyle?.icon_state || "",
    facialColor: data.facial_color,
    facialDmiFile,
    eyeColor: data.eye_color,
    bodyDmiFile: speciesInfo.icobase,
    organData: data.organ_data,
    rlimbData: data.rlimb_data,
    robolimbIcons,
    underwear,
    clothing,
    markings,
    hairMarkings,
    hideHair: !!data.hide_hair,
    hideFacialHair: !!data.hide_facial_hair,
  };
}

/** Build a render config from slot appearance data (for slot picker thumbnails) */
function buildSlotRenderConfig(
  appearance: SlotAppearanceData,
  data: CharacterData,
): CharacterRenderConfig | null {
  if (!appearance.icobase) return null;

  const { buildIndex, hairDmiFile, facialDmiFile, hairStyle, facialStyle } =
    resolveHairInfo(data, appearance.body || "Default", appearance.hair_key, appearance.h_style, appearance.f_style);

  return {
    species: appearance.species,
    gender: appearance.gender,
    bodyBuild: buildIndex,
    direction: SOUTH,
    skinTone: appearance.s_tone || 0,
    skinColor: (appearance.appearance_flags & HAS_SKIN_COLOR) ? appearance.skin_color : null,
    hairStyle: hairStyle?.icon_state || "",
    hairColor: appearance.hair_color,
    secondaryHairColor: hairStyle?.has_secondary ? appearance.s_hair_color : null,
    hairDmiFile,
    facialStyle: facialStyle?.icon_state || "",
    facialColor: appearance.facial_color,
    facialDmiFile,
    eyeColor: appearance.eye_color,
    bodyDmiFile: appearance.icobase,
  };
}

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
}) => {
  const btn = (
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
  if (props.tooltip) {
    return <Tooltip content={props.tooltip}>{btn}</Tooltip>;
  }
  return btn;
};


// ================================================================
// Category definitions
// ================================================================

const CATEGORIES = [
  { id: "identity", label: "Identity", icon: "user" },
  { id: "wardrobe", label: "Loadout", icon: "tshirt" },
  { id: "augmentations", label: "Augments", icon: "cog" },
  { id: "career", label: "Job", icon: "briefcase" },
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
                onSelect={(id) => {
                  if (id !== category && category === "wardrobe") {
                    act("selectGear", { hash: "" });
                  }
                  setCategory(id);
                }}
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

const DIR_CYCLE = [SOUTH, EAST, NORTH, WEST];

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
        tooltip="Rotate left"
        onClick={() => act("rotatePreview", { dir: rotateDir(currentDir, -1) })}
      />
      <CsButton
        compact
        icon="chevron-right"
        tooltip="Rotate right"
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
    act("loadSlot", { slot });
  };

  const displayName = currentSlotName.length > 14
    ? currentSlotName.slice(0, 13) + "…"
    : currentSlotName;

  return (
    <Box className="CharSetup__slotSelectorWrap">
      <Box className="CharSetup__slotSelector">
        <Box
          className="CharSetup__slotName"
          onClick={handleOpenPicker}
          style={{ cursor: "pointer" }}
        >
          <Box className="CharSetup__slotNameLabel">
            {displayName}
            <Icon
              name={showPicker ? "chevron-up" : "chevron-down"}
              ml={0.5}
              style={{ fontSize: "0.6875rem", opacity: 0.5 }}
            />
          </Box>
          <Box className="CharSetup__slotNumber">
            {data.default_slot} / {data.config.character_slots}
          </Box>
        </Box>
        <CsButton
          compact
          icon="undo"
          color="bad"
          tooltip="Reset character"
          onClick={() => act("confirmResetSlot")}
        />
      </Box>

      {/* Inline slot picker — pushes sidebar down when open */}
      {showPicker && (
        <Box className="CharSetup__slotPicker">
          <Box className="CharSetup__slotPickerGrid">
            {(data.slot_previews || data.character_slots_info || []).map(
              (slotInfo: any) => {
                const appearance = slotInfo.appearance || null;
                const isEmpty = !appearance;
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
                      {appearance ? (
                        <SlotThumbnail
                          appearance={appearance}
                          data={data}
                          size={64}
                        />
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

/** Generate a cache key from the render-affecting preference fields */
function previewCacheKey(data: CharacterData): string {
  return [
    data.species, data.gender, data.body, data.preview_dir,
    data.s_tone, data.skin_color, data.h_style, data.hair_color,
    data.s_hair_color, data.f_style, data.facial_color,
    data.eye_color, data.body_height,
    JSON.stringify(data.organ_data),
    JSON.stringify(data.rlimb_data),
    JSON.stringify(data.underwear_render),
    JSON.stringify(data.all_underwear),
    JSON.stringify(data.equipment_render),
    JSON.stringify(data.body_markings),
    data.hide_hair, data.hide_facial_hair,
  ].join("|");
}

/** Canvas-based character preview using the sprite compositor */
class CharacterCanvas extends Component<
  { data: CharacterData },
  { ready: boolean }
> {
  private initPromise: Promise<void> | null = null;
  private lastCacheKey = "";
  private canvasRef: HTMLCanvasElement | null = null;

  constructor(props) {
    super(props);
    this.state = { ready: false };
    this.setCanvasRef = this.setCanvasRef.bind(this);
  }

  setCanvasRef(el: HTMLCanvasElement | null) {
    this.canvasRef = el;
  }

  componentDidMount() {
    this.initCompositor();
  }

  componentDidUpdate() {
    if (this.state.ready) {
      const key = previewCacheKey(this.props.data);
      if (key !== this.lastCacheKey) {
        this.lastCacheKey = key;
        this.doRender();
      }
    }
  }

  async initCompositor() {
    if (this.initPromise) return;
    const compositor = getCompositor();
    if (compositor.isReady()) {
      this.setState({ ready: true });
      this.lastCacheKey = previewCacheKey(this.props.data);
      this.doRender();
      return;
    }
    this.initPromise = compositor.init().then(() => {
      this.setState({ ready: true });
      this.lastCacheKey = previewCacheKey(this.props.data);
      this.doRender();
    }).catch(() => {
      // Compositor failed to load
    });
  }

  doRender() {
    const compositor = getCompositor();
    if (!compositor.isReady() || !this.canvasRef) return;

    const config = buildRenderConfig(this.props.data);
    if (!config) return;

    // Synchronous direct-to-canvas render — no data URL, no async onload, no flicker.
    compositor.renderCharacterToCanvas(config, this.canvasRef);
  }

  render() {
    const { ready } = this.state;

    return (
      <>
        <canvas
          ref={this.setCanvasRef}
          className="CharSetup__previewCanvas"
          width={192}
          height={192}
          style={{ display: ready ? undefined : 'none' }}
        />
        {!ready && (
          <Box className="CharSetup__previewLoading">
            <Icon name="spinner" spin size={3} />
          </Box>
        )}
      </>
    );
  }
}

/** Renders a mini character thumbnail from slot appearance data */
class SlotThumbnail extends Component<
  { appearance: SlotAppearanceData; data: CharacterData; size?: number },
  { url: string }
> {
  private lastKey = "";

  constructor(props) {
    super(props);
    this.state = { url: "" };
  }

  componentDidMount() {
    this.tryRender();
  }

  componentDidUpdate() {
    const key = JSON.stringify(this.props.appearance);
    if (key !== this.lastKey) {
      this.lastKey = key;
      this.tryRender();
    }
  }

  tryRender() {
    const compositor = getCompositor();
    if (!compositor.isReady()) return;
    const config = buildSlotRenderConfig(
      this.props.appearance,
      this.props.data,
    );
    if (!config) return;
    const url = compositor.renderThumbnail(config, this.props.size || 64);
    if (url) {
      this.setState({ url });
    }
  }

  render() {
    if (this.state.url) {
      return (
        <img
          className="CharSetup__slotPickerPreviewImg"
          src={this.state.url}
        />
      );
    }
    return <Icon name="user" style={{ opacity: 0.3 }} />;
  }
}

/** Renders a compositor-based preview at arbitrary size, using current data */
class CompositorPreview extends Component<
  { data: CharacterData; size?: number; className?: string },
  { url: string }
> {
  private lastKey = "";

  constructor(props) {
    super(props);
    this.state = { url: "" };
  }

  componentDidMount() {
    this.tryRender();
  }

  componentDidUpdate() {
    const key = previewCacheKey(this.props.data);
    if (key !== this.lastKey) {
      this.lastKey = key;
      this.tryRender();
    }
  }

  tryRender() {
    const compositor = getCompositor();
    if (!compositor.isReady()) {
      compositor.init().then(() => this.tryRender()).catch(() => {});
      return;
    }
    const config = buildRenderConfig(this.props.data);
    if (!config) return;
    const url = compositor.renderCharacter(
      config,
      this.props.size || 64,
    );
    if (url) {
      this.setState({ url });
    }
  }

  render() {
    if (this.state.url) {
      return (
        <img
          className={this.props.className || "CharSetup__compositorPreview"}
          src={this.state.url}
        />
      );
    }
    return (
      <Box className="CharSetup__previewLoading">
        <Icon name="spinner" spin size={2} />
      </Box>
    );
  }
}

/**
 * Renders a single item icon from the sprite atlas.
 * Used for gear list items and gear detail views.
 */
class GearSpriteIcon extends Component<
  { dmiFile: string; state: string; color?: string; size?: number },
  { url: string }
> {
  constructor(props) {
    super(props);
    this.state = { url: "" };
  }

  componentDidMount() {
    this.tryRender();
  }

  componentDidUpdate(prevProps) {
    if (
      prevProps.dmiFile !== this.props.dmiFile ||
      prevProps.state !== this.props.state ||
      prevProps.color !== this.props.color
    ) {
      this.tryRender();
    }
  }

  tryRender() {
    const compositor = getCompositor();
    if (!compositor.isReady()) return;
    const url = compositor.renderItemIcon(
      this.props.dmiFile,
      this.props.state,
      this.props.size || 32,
      this.props.color || undefined,
    );
    if (url) {
      this.setState({ url });
    }
  }

  render() {
    if (this.state.url) {
      return (
        <img
          className="CharSetup__gearSpriteIcon"
          src={this.state.url}
        />
      );
    }
    return <Icon name="question" />;
  }
}

const CharacterPreview = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act } = props;

  return (
    <Box className="CharSetup__preview">
      {/* Preview sprite — client-side compositor with server fallback */}
      <Box className="CharSetup__previewFrame">
        <CharacterCanvas data={data} />
      </Box>

      {/* Direction controls — turn left / right */}
      <RotateControls currentDir={data.preview_dir} act={act} />

      {/* Name display */}
      <Box className="CharSetup__previewName">
        {data.real_name}
      </Box>
      <Box className="CharSetup__previewMeta">
        {data.species} &middot; {data.gender === "male" ? "M" : data.gender === "female" ? "F" : data.gender?.charAt(0).toUpperCase()}{" "}
        &middot; {data.age}
      </Box>

      {/* Quick actions + preview toggles — compact row */}
      <Box className="CharSetup__actionRow">
        <CsButton
          compact
          icon="dice"
          onClick={() => act("randomizeAppearance")}
          tooltip="Randomize appearance"
        />
        <CsButton
          compact
          icon="undo"
          disabled={!data.can_undo}
          onClick={() => act("undo")}
          tooltip="Undo last change"
        />
        <CsButton
          compact
          icon="save"
          onClick={() => act("saveSlot")}
          tooltip="Save character"
        />
        <CsButton
          compact
          icon="tshirt"
          tooltip="Toggle job gear preview"
          selected={!!(data.equip_preview_mob & EQUIP_PREVIEW_JOB)}
          onClick={() =>
            act("togglePreviewFlag", { flag: EQUIP_PREVIEW_JOB })
          }
        />
        <CsButton
          compact
          icon="box-open"
          tooltip="Toggle loadout preview"
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
              <CompositorPreview
                data={data}
                size={64}
                className="CharSetup__idCardHeadshot"
              />
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
                  tooltip="Randomize name"
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
                  tooltip={showSpeciesInfo ? "Hide species info" : "Show species info"}
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

          {/* Gender + Age row */}
          <Box className="CharSetup__idCardFieldRow">
            <Box className="CharSetup__idCardField" style={{ flex: "1" }}>
              <Box className="CharSetup__idCardFieldLabel">Gender</Box>
              <Box>
                {(speciesInfo?.genders || ["male", "female"]).map((g) => (
                  <CsButton
                    key={g}
                    compact
                    selected={data.gender === g}
                    icon={g === "male" ? "mars" : g === "female" ? "venus" : "genderless"}
                    color={data.gender === g ? (g === "male" ? "blue" : g === "female" ? "pink" : "grey") : undefined}
                    tooltip={g === "male" ? "Male" : g === "female" ? "Female" : g}
                    onClick={() => act("setGender", { gender: g })}
                  />
                ))}
              </Box>
            </Box>
            <Box className="CharSetup__idCardField" style={{ flex: "1" }}>
              <Box className="CharSetup__idCardFieldLabel">Age</Box>
              <Box className="CharSetup__ageInputWrap">
                <NumberInput
                  value={data.age}
                  minValue={speciesInfo?.min_age || 17}
                  maxValue={speciesInfo?.max_age || 85}
                  step={1}
                  onChange={(e, val) => act("setAge", { age: val })}
                />
              </Box>
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
            <Dropdown
              width="9rem"
              reselectable
              selected={
                data.body_heights.find((h) => h.value === data.body_height)
                  ?.label || ""
              }
              options={data.body_heights.map((h) => h.label)}
              onSelected={(label: string) => {
                const h = data.body_heights.find((h) => h.label === label);
                if (h) act("setHeight", { height: h.value });
              }}
            />
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

          {/* Origin section */}
          <Box className="CharSetup__idCardSectionSep">Origin</Box>

          {/* Faction + Religion + Home System — one row, width-capped to avoid stamp */}
          <Box className="CharSetup__idCardFieldRow" style={{ maxWidth: "calc(100% - 9rem)" }}>
            <Box className="CharSetup__idCardField">
              <Box className="CharSetup__idCardFieldLabel">Faction</Box>
              <Dropdown
                fluid
                selected={data.background}
                options={data.backgrounds || []}
                onSelected={(val: string) =>
                  act("setBackground", { value: val })
                }
              />
            </Box>
            <Box className="CharSetup__idCardField">
              <Box className="CharSetup__idCardFieldLabel">Religion</Box>
              <Dropdown
                fluid
                selected={data.religion}
                options={data.religions || []}
                onSelected={(val: string) =>
                  act("setReligion", { value: val })
                }
              />
            </Box>
            <Box className="CharSetup__idCardField">
              <Box className="CharSetup__idCardFieldLabel">
                Home System
              </Box>
              <Dropdown
                fluid
                selected={data.home_system}
                options={data.home_systems || []}
                onSelected={(val: string) =>
                  act("setHomeSystem", { value: val })
                }
              />
            </Box>
          </Box>
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
            <Box className="CharSetup__skinToneSlider">
              <Slider
                value={-data.s_tone + 35}
                minValue={0}
                maxValue={speciesInfo?.max_skin_tone || 220}
                step={1}
                stepPixelSize={3}
                onChange={(e, val) => act("setSkinTone", { tone: -(val - 35) })}
              />
            </Box>
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
                  <SearchDropdown
                    fluid
                    placeholder="Search styles..."
                    selected={data.h_style}
                    options={validHairStyles}
                    onSelected={(val) => act("setHairStyle", { style: val })}
                  />
                  <Box mt={0.25}>
                    <CsButton
                      compact
                      icon="chevron-left"
                      tooltip="Previous style"
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
                      tooltip="Next style"
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
                  <SearchDropdown
                    fluid
                    placeholder="Search styles..."
                    selected={data.f_style}
                    options={validFacialStyles}
                    onSelected={(val) => act("setFacialStyle", { style: val })}
                  />
                  <Box mt={0.25}>
                    <CsButton
                      compact
                      icon="chevron-left"
                      tooltip="Previous style"
                      onClick={() => {
                        const idx = validFacialStyles.indexOf(data.f_style);
                        const prev = idx <= 0
                          ? validFacialStyles[validFacialStyles.length - 1]
                          : validFacialStyles[idx - 1];
                        act("setFacialStyle", { style: prev });
                      }}
                    />
                    <CsButton
                      compact
                      icon="chevron-right"
                      tooltip="Next style"
                      ml={0.25}
                      onClick={() => {
                        const idx = validFacialStyles.indexOf(data.f_style);
                        const next = idx >= validFacialStyles.length - 1
                          ? validFacialStyles[0]
                          : validFacialStyles[idx + 1];
                        act("setFacialStyle", { style: next });
                      }}
                    />
                  </Box>
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
                    tooltip="Pick eye color"
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
                    tooltip="Pick hair color"
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
                    tooltip="Pick secondary hair color"
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
                    tooltip="Pick facial hair color"
                    onClick={() => act("pickColor", { which: "facial" })}
                  />
                </Box>
              )}

            </Box>

            {/* THIRD COL — Languages */}
            <Box className="CharSetup__idCardBackCol">
              <LanguagesCompact data={data} act={act} />
            </Box>
          </Box>
        )}

        {/* Body Markings */}
        <Box mb={0.5}>
          <Box className="CharSetup__idCardBackLabel">Body Markings</Box>
          <Box style={{ "max-height": "6rem", "overflow-y": "auto" }}>
            {(data.body_markings || []).map((m) => (
              <Box key={m.name} className="CharSetup__idCardMarkingRow">
                <Box style={{ flex: "1" }}>{m.name}</Box>
                <Box
                  className="CharSetup__idCardColorSwatch"
                  style={{ "background-color": m.color, width: "1.125rem", height: "1.125rem" }}
                />
                <CsButton
                  compact
                  icon="palette"
                  tooltip="Pick color"
                  onClick={() => act("pickMarkingColor", { marking: m.name })}
                />
                <CsButton
                  compact
                  icon="times"
                  color="danger"
                  tooltip="Remove marking"
                  onClick={() => act("removeBodyMarking", { marking: m.name })}
                />
              </Box>
            ))}
          </Box>
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
  { name: "Shoes", icon: "shoe-prints" },
];

// --- Compact slot tile for the left pane ---

const SlotTile = (props: {
  slot: SlotLabel;
  equipped: GearItem[] | undefined;
  isActive: boolean;
  onSelect: (name: string) => void;
}) => {
  const { slot, equipped, isActive, onSelect } = props;
  const hasEquipped = equipped && equipped.length > 0;
  return (
    <Box
      className={classes([
        "CharSetup__slotTile",
        isActive && "CharSetup__slotTile--active",
        hasEquipped && "CharSetup__slotTile--equipped",
      ])}
      onClick={() => onSelect(slot.name)}
    >
      <Box className="CharSetup__slotTileIcon">
        {hasEquipped && equipped![0].icon && equipped![0].iconState ? (
          <GearSpriteIcon
            dmiFile={equipped![0].icon!}
            state={equipped![0].iconState!}
            size={32}
          />
        ) : (
          <Icon name={slot.icon} />
        )}
      </Box>
      <Box className="CharSetup__slotTileText">
        {hasEquipped ? (
          <>
            <Box className="CharSetup__slotTileName">
              {equipped!.length === 1
                ? equipped![0].name
                : `${equipped!.length} items`}
            </Box>
            <Box className="CharSetup__slotTileSlot">{slot.name}</Box>
          </>
        ) : (
          <Box className="CharSetup__slotTileName">{slot.name}</Box>
        )}
      </Box>
    </Box>
  );
};

// --- Compact slot icon button (used in the icon bar below the doll) ---

const SLOT_ABBR: Record<string, string> = {
  "Head": "HEAD", "Eyes": "EYES", "Mask": "MASK", "Accessory": "ACC",
  "Uniform": "UNIF", "Suit": "SUIT", "Gloves": "GLOV", "Shoes": "SHOE",
};

const SlotIconBtn = (props: {
  slot: SlotLabel;
  equipped: GearItem[] | undefined;
  isActive: boolean;
  onSelect: (name: string) => void;
}) => {
  const { slot, equipped, isActive, onSelect } = props;
  const hasEquipped = equipped && equipped.length > 0;
  return (
    <Box
      className={classes([
        "CharSetup__slotIconBtn",
        isActive && "CharSetup__slotIconBtn--active",
        hasEquipped && "CharSetup__slotIconBtn--equipped",
      ])}
      onClick={() => onSelect(slot.name)}
    >
      <Box className="CharSetup__slotIconBtnIcon">
        {hasEquipped && equipped![0].icon && equipped![0].iconState ? (
          <GearSpriteIcon
            dmiFile={equipped![0].icon!}
            state={equipped![0].iconState!}
            size={24}
          />
        ) : (
          <Icon name={slot.icon} />
        )}
      </Box>
      <Box className="CharSetup__slotIconBtnLabel">
        {SLOT_ABBR[slot.name] || slot.name.substring(0, 4).toUpperCase()}
      </Box>
    </Box>
  );
};

// --- Character doll — preview with body-part sprite highlight overlays ---

/**
 * Slots selectable by clicking on the doll, checked in priority order.
 * organTags  → body-part sprite used for hit shape.
 * clothingItem → placeholder equipment sprite used for hit shape (Eyes, Mask).
 */
const ZONE_SLOTS: Array<{
  slot: string;
  organTags?: string[];
  clothingItem?: { dmiFile: string; state: string };
}> = [
  { slot: "Gloves",  organTags: ["l_hand", "r_hand"] },
  { slot: "Shoes",   organTags: ["l_foot", "r_foot"] },
  { slot: "Suit",    organTags: ["l_arm", "r_arm"] },
  { slot: "Eyes",    clothingItem: { dmiFile: "icons/inv_slots/glasses/mob.dmi", state: "glasses" } },
  { slot: "Mask",    clothingItem: { dmiFile: "icons/inv_slots/masks/mob.dmi",   state: "sterile" } },
  { slot: "Head",    organTags: ["head"] },
  { slot: "Uniform", organTags: ["chest", "groin"] },
];

/**
 * Body-part based highlights for slots shown when a tile is selected.
 * Eyes and Mask use equipment sprites (handled in buildHighlights via ZONE_SLOTS).
 */
const SLOT_ORGAN_TAGS: Record<string, string[]> = {
  "Head":      ["head"],
  "Accessory": ["chest", "groin"],
  "Uniform":   ["chest", "groin"],
  "Suit":      ["l_arm", "r_arm"],
  "Gloves":    ["l_hand", "r_hand"],
  "Shoes":     ["l_foot", "r_foot"],
};

/** Cache key for the parts of data that affect body-part silhouette rendering */
function dollCacheKey(data: CharacterData, dir: number): string {
  return `${data.species}|${data.gender}|${data.body || ""}|${dir}`;
}

interface CharacterDollProps {
  data: CharacterData;
  equippedBySlot: Record<string, GearItem[]>;
  selectedSlotName: string | null;
  onSelectSlot: (name: string) => void;
  currentDir: number;
  act: Function;
}

interface CharacterDollState {
  hoveredSlot: string | null;
  /** Teal silhouette data URLs for display (all slots including non-zone ones) */
  highlightUrls: Record<string, string>;
  /** Canvases built from data URLs for pixel-perfect hit testing (zone slots only) */
  hitCanvases: Record<string, HTMLCanvasElement>;
  cacheKey: string;
}

class CharacterDoll extends Component<CharacterDollProps, CharacterDollState> {
  state: CharacterDollState = {
    hoveredSlot: null,
    highlightUrls: {},
    hitCanvases: {},
    cacheKey: "",
  };

  private containerEl: HTMLElement | null = null;

  componentDidMount() {
    this.buildHighlights();
  }

  componentDidUpdate() {
    const key = dollCacheKey(this.props.data, this.props.currentDir);
    if (key !== this.state.cacheKey) {
      this.buildHighlights();
    }
  }

  buildHighlights() {
    const compositor = getCompositor();
    if (!compositor.isReady()) return;
    const config = buildRenderConfig(this.props.data);
    if (!config) return;

    const key = dollCacheKey(this.props.data, this.props.currentDir);
    const teal = "rgba(77,182,172,1)";

    // Render display highlights: body-part based slots
    const highlightUrls: Record<string, string> = {};
    for (const [slot, organTags] of Object.entries(SLOT_ORGAN_TAGS)) {
      highlightUrls[slot] = compositor.renderBodyPartHighlight(config, organTags, teal, 320);
    }
    // Equipment-sprite based slots (Eyes, Mask) — shown on doll as actual item silhouettes
    for (const zone of ZONE_SLOTS) {
      if (zone.clothingItem) {
        highlightUrls[zone.slot] = compositor.renderEquipmentHighlight(
          config.direction, zone.clothingItem.dmiFile, zone.clothingItem.state, teal, 320,
        );
      }
    }

    // Build hit-test canvases from data URLs.
    // Data URLs are same-origin — getImageData() will succeed for pixel-perfect testing.
    const hitCanvases: Record<string, HTMLCanvasElement> = {};
    let pending = ZONE_SLOTS.length;

    const done = () => {
      if (pending <= 0) {
        this.setState({ highlightUrls, hitCanvases, cacheKey: key });
      }
    };

    for (const zone of ZONE_SLOTS) {
      const url = highlightUrls[zone.slot];
      if (!url) { pending--; done(); continue; }

      const canvas = document.createElement("canvas");
      canvas.width = 320;
      canvas.height = 320;
      const ctx = canvas.getContext("2d")!;
      const img = new Image();
      img.onload = () => {
        ctx.drawImage(img, 0, 0);
        hitCanvases[zone.slot] = canvas;
        pending--;
        done();
      };
      img.onerror = () => { pending--; done(); };
      img.src = url;
    }

    if (ZONE_SLOTS.length === 0) done();
  }

  handleMouseMove = (e: MouseEvent) => {
    const { hitCanvases } = this.state;
    if (!this.containerEl) return;

    const rect = this.containerEl.getBoundingClientRect();
    const x = Math.floor(((e.clientX - rect.left) / rect.width) * 320);
    const y = Math.floor(((e.clientY - rect.top) / rect.height) * 320);
    if (x < 0 || y < 0 || x >= 320 || y >= 320) return;

    // Check each zone in priority order — first with a non-transparent pixel wins
    for (const { slot } of ZONE_SLOTS) {
      const canvas = hitCanvases[slot];
      if (!canvas) continue;
      try {
        const alpha = canvas.getContext("2d")!.getImageData(x, y, 1, 1).data[3];
        if (alpha > 10) {
          if (this.state.hoveredSlot !== slot) {
            this.setState({ hoveredSlot: slot });
          }
          return;
        }
      } catch (_) {
        // Canvas tainted in dev context — silently skip
      }
    }

    if (this.state.hoveredSlot !== null) {
      this.setState({ hoveredSlot: null });
    }
  };

  handleMouseLeave = () => {
    if (this.state.hoveredSlot !== null) {
      this.setState({ hoveredSlot: null });
    }
  };

  handleClick = () => {
    if (this.state.hoveredSlot) {
      this.props.onSelectSlot(this.state.hoveredSlot);
    }
  };

  render() {
    const { data, equippedBySlot, selectedSlotName, currentDir, act } = this.props;
    const { hoveredSlot, highlightUrls } = this.state;
    const activeSlot = hoveredSlot || selectedSlotName;

    return (
      <>
        <div
          className="CharSetup__dollContainer"
          ref={(el: HTMLElement) => { this.containerEl = el; }}
          onMouseMove={this.handleMouseMove}
          onMouseLeave={this.handleMouseLeave}
          onClick={this.handleClick}
          style={{ cursor: hoveredSlot ? "pointer" : "default" }}
        >
          {/* Main character preview — highlights live inside so z-index works correctly */}
          <Box className="CharSetup__paperDollCenter">
            <CompositorPreview
              data={data}
              size={320}
              className="CharSetup__paperDollSprite"
            />
            {Object.entries(highlightUrls).map(([slot, url]) => {
              const isHovered = hoveredSlot === slot;
              const isEquipped = equippedBySlot[slot]?.length > 0;
              return (
                <img
                  key={`hl-${slot}`}
                  src={url}
                  className={classes([
                    "CharSetup__dollPartHighlight",
                    isHovered && "CharSetup__dollPartHighlight--hovered",
                    isEquipped && !isHovered && "CharSetup__dollPartHighlight--equipped",
                  ])}
                />
              );
            })}
          </Box>

          {/* Slot name label — hover only, fades when mouse leaves */}
          {hoveredSlot && (
            <Box className="CharSetup__dollZoneLabel">{hoveredSlot}</Box>
          )}
        </div>

        <RotateControls currentDir={currentDir} act={act} />
      </>
    );
  }
}

// Categories that map directly to body slots
// and hidden from the misc category browser.
const SLOT_CATEGORIES = new Set([
  "Hats", "Glasses", "Masks", "Earwear", "Gloves", "Shoes",
  "Suits", "Uniforms", "Clothing Pieces",
]);

// --- Misc item browser: collapsible categories ---

interface MiscCategory {
  name: string;
  items: GearItem[];
}

const MiscItemBrowser = (props: {
  categories: MiscCategory[];
  equippedGear: Record<string, boolean>;
  selectedHash: string | null;
  onSelectGear?: () => void;
  act: Function;
  context: any;
}) => {
  const { categories, equippedGear, selectedHash, onSelectGear, act, context } = props;
  const [expandedCats, setExpandedCats] = useLocalState<Record<string, boolean>>(
    context, "miscExpandedCats", {}
  );

  const isExpanded = (name: string) => expandedCats[name] !== false;
  const toggleCat = (name: string) =>
    setExpandedCats({ ...expandedCats, [name]: !isExpanded(name) });

  if (!categories || categories.length === 0) {
    return (
      <Box color="label" textAlign="center" mt={2}>
        No misc items available.
      </Box>
    );
  }

  return (
    <Box>
      {categories.map((cat) => (
        <Box key={cat.name} mb={0.25}>
          <Box
            className="CharSetup__miscCatHeader"
            onClick={() => toggleCat(cat.name)}
          >
            <Box className="CharSetup__miscCatHeader__label">{cat.name}</Box>
            <Icon name={isExpanded(cat.name) ? "chevron-down" : "chevron-right"} color="label" />
          </Box>
          {isExpanded(cat.name) && (
            <LoadoutItemList
              items={cat.items}
              equippedGear={equippedGear}
              selectedHash={selectedHash}
              onSelectGear={onSelectGear}
              act={act}
              context={context}
            />
          )}
        </Box>
      ))}
    </Box>
  );
};

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

  const [detailOpen, setDetailOpen] = useLocalState(
    context,
    "loadoutDetailOpen",
    false
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

  // Determine display items (equipment / search modes)
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

  // Filter misc categories too
  const filteredMiscCategories = miscCategories.map((cat) => ({
    ...cat,
    items: cat.items.filter((item) => {
      if (data.hideUnavailable && !item.allowed && !data.equippedGear?.[item.hash]) return false;
      if (data.hideDonate && (item.price || item.patronTier)) return false;
      return true;
    }),
  })).filter((cat) => cat.items.length > 0);

  // Right-panel item browser
  const itemBrowser = (
    <Stack vertical fill>
      <Stack.Item grow basis={0} style={{ overflow: "auto" }}>
        {wardrobeView === "misc" && !searchText ? (
          <MiscItemBrowser
            categories={filteredMiscCategories}
            equippedGear={data.equippedGear}
            selectedHash={data.selectedGearHash}
            onSelectGear={() => setDetailOpen(true)}
            act={act}
            context={context}
          />
        ) : showingItems ? (
          <LoadoutItemList
            items={displayItems}
            equippedGear={data.equippedGear}
            selectedHash={data.selectedGearHash}
            onSelectGear={() => setDetailOpen(true)}
            act={act}
            context={context}
          />
        ) : (
          <Box className="CharSetup__wardrobeHint">
            <Icon name="hand-pointer" size={2} />
            Select a slot or search
          </Box>
        )}
      </Stack.Item>
      {(showingItems || (wardrobeView === "misc" && !searchText)) && detailOpen && data.selectedGearDetail && (
        <Stack.Item>
          <Stack align="center">
            <Stack.Item grow>
              <Divider />
            </Stack.Item>
            <Stack.Item>
              <CsButton
                compact
                icon="times"
                onClick={() => {
                  setDetailOpen(false);
                  act("selectGear", { hash: "" });
                }}
              />
            </Stack.Item>
          </Stack>
          <Box style={{ maxHeight: "9rem", overflowY: "auto" }}>
            <LoadoutItemDetail
              detail={data.selectedGearDetail}
              tweaks={data.selectedGearTweaks}
              act={act}
            />
          </Box>
        </Stack.Item>
      )}
    </Stack>
  );

  const lpRatio = data.maxLoadoutPoints > 0
    ? Math.min(data.usedLoadoutPoints / data.maxLoadoutPoints, 1)
    : 0;
  const lpOverBudget = data.usedLoadoutPoints > data.maxLoadoutPoints;

  return (
    <Stack vertical fill>
      {/* ── Fancy HUD bar ── */}
      <Stack.Item>
        <Box className="CharSetup__loadoutHud">
          {/* LP progress row */}
          <Box className="CharSetup__loadoutHudRow">
            <Box className="CharSetup__loadoutHudLabel">
              <Icon name="suitcase" mr={0.5} />
              LOADOUT POINTS
            </Box>
            <Box className={classes([
              "CharSetup__lpBarWrap",
              lpOverBudget && "CharSetup__lpBarWrap--over",
            ])}>
              <Box
                className={classes([
                  "CharSetup__lpBarFill",
                  lpOverBudget && "CharSetup__lpBarFill--over",
                ])}
                style={{ width: `${lpRatio * 100}%` }}
              />
              <Box className="CharSetup__lpBarText">
                {data.usedLoadoutPoints} / {data.maxLoadoutPoints} LP
              </Box>
            </Box>
            {data.currentOpyxes > 0 && (
              <Box
                inline
                fontSize="11px"
                color="gold"
                style={{ whiteSpace: "nowrap", alignSelf: "center", marginRight: "0.25rem" }}
              >
                <Icon name="coins" mr={0.25} />
                {data.currentOpyxes}
              </Box>
            )}
            <CsButton compact icon="random" onClick={() => act("randomizeLoadout")} tooltip="Random loadout" />
            <CsButton compact icon="trash-alt" onClick={() => act("clearLoadout")} tooltip="Clear loadout" />
          </Box>
          {/* Backpack + type tweak row */}
          <Box className="CharSetup__loadoutHudSetRow">
            <Box className="CharSetup__loadoutHudLabel">
              <Icon name="backpack" mr={0.5} />
              BACKPACK
            </Box>
            <Dropdown
              selected={data.backpack}
              options={data.backpack_types}
              onSelected={(val) => act("setBackpack", { name: val })}
            />
            {data.backpack_tweaks && data.backpack_tweaks.map((tweak, i) => (
              <Dropdown
                key={i}
                selected={tweak.current}
                options={tweak.options}
                onSelected={(val) => act("setBackpackTweak", { tweakIndex: tweak.tweakIndex, value: val })}
              />
            ))}
          </Box>
          {/* Set navigation row */}
          <Box className="CharSetup__loadoutHudSetRow">
            <CsButton
              compact
              icon="chevron-left"
              tooltip="Previous gear set"
              onClick={() =>
                act("setGearSlot", {
                  slot: data.currentGearSlot <= 1
                    ? data.config.loadout_slots
                    : data.currentGearSlot - 1,
                })
              }
            />
            <Box className="CharSetup__loadoutHudSetLabel">
              SET {data.currentGearSlot} / {data.config.loadout_slots}
            </Box>
            <CsButton
              compact
              icon="chevron-right"
              tooltip="Next gear set"
              onClick={() =>
                act("setGearSlot", {
                  slot: data.currentGearSlot >= data.config.loadout_slots
                    ? 1
                    : data.currentGearSlot + 1,
                })
              }
            />
          </Box>
        </Box>
      </Stack.Item>

      {/* Search + filters row */}
      <Stack.Item>
        <Stack align="center">
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
              tooltip={data.hideUnavailable ? "Show unavailable" : "Hide unavailable"}
              onClick={() => act("toggleHideUnavailable")}
            />
          </Stack.Item>
          <Stack.Item>
            <CsButton
              compact
              icon="coins"
              selected={data.hideDonate}
              tooltip={data.hideDonate ? "Show donation items" : "Hide donation items"}
              onClick={() => act("toggleHideDonate")}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      {/* Body: [doll + slot bar + misc button + underwear] | [item browser] */}
      <Stack.Item grow basis={0}>
        <Box className="CharSetup__wardrobeLayout">
          {/* Center column: doll, slot icon bar, misc button, underwear */}
          <Box className="CharSetup__wardrobeCenter">
            <CharacterDoll
              data={data}
              equippedBySlot={equippedBySlot}
              selectedSlotName={selectedSlotName}
              onSelectSlot={(name) => {
                setSelectedSlotName(name);
                setWardrobeView("equipment");
                setDetailOpen(false);
                act("selectGear", { hash: "" });
                setSearchText("");
              }}
              currentDir={data.preview_dir}
              act={act}
            />

              {/* Slot icon bar — 4×2 grid below the doll */}
              <Box className="CharSetup__slotIconBar">
                {SLOT_LABELS.map((slot) => (
                  <SlotIconBtn
                    key={slot.name}
                    slot={slot}
                    equipped={equippedBySlot[slot.name]}
                    isActive={wardrobeView === "equipment" && selectedSlotName === slot.name && !searchText}
                    onSelect={(name) => {
                      setSelectedSlotName(name);
                      setWardrobeView("equipment");
                      setDetailOpen(false);
                      act("selectGear", { hash: "" });
                      setSearchText("");
                    }}
                  />
                ))}
              </Box>

              {/* MISC wide button — third row below slot grid */}
              <Box
                className={classes([
                  "CharSetup__miscBtn",
                  wardrobeView === "misc" && !searchText && "CharSetup__miscBtn--active",
                ])}
                onClick={() => {
                  setSearchText("");
                  setWardrobeView("misc");
                  setSelectedSlotName(null);
                  setDetailOpen(false);
                  act("selectGear", { hash: "" });
                }}
              >
                <Box className="CharSetup__miscBtnIcon">
                  <Icon name="box-open" />
                </Box>
                <Box className="CharSetup__miscBtnLabel">Misc</Box>
              </Box>

              {/* Underwear + Backpack — compact row below slot bar */}
              <Box className="CharSetup__dollUnderwear">
                {data.underwear_categories.map((cat) => {
                  const selected = data.all_underwear?.[cat.name] || "None";
                  const isColorable = cat.colorable?.includes(selected);
                  const currentColor = data.all_underwear_color?.[cat.name];
                  return (
                    <Box key={cat.name} className="CharSetup__dollUnderwearItem">
                      <Box className="CharSetup__dollUnderwearLabel">{cat.name}</Box>
                      <Box className="CharSetup__dollUnderwearRow">
                        <Dropdown
                          fluid
                          selected={selected}
                          options={cat.items}
                          onSelected={(val: string) =>
                            act("setUnderwear", { category: cat.name, name: val })
                          }
                        />
                        {isColorable && (
                          <Box
                            className="CharSetup__uwColorSwatch"
                            style={{ "background-color": currentColor || "#ffffff" }}
                            onClick={() => act("setUnderwearColor", { category: cat.name })}
                            title="Pick color"
                          />
                        )}
                      </Box>
                    </Box>
                  );
                })}
              </Box>
            </Box>

            {/* Right: item browser */}
            <Box className="CharSetup__wardrobeRight">
              {itemBrowser}
            </Box>
          </Box>
      </Stack.Item>
    </Stack>
  );
};

// --- Loadout item list ---

interface ContextMenuState {
  x: number;
  y: number;
  item: GearItem;
  isEquipped: boolean;
}

const LoadoutItemList = (props: {
  items: GearItem[];
  equippedGear: Record<string, boolean>;
  selectedHash: string | null;
  onSelectGear?: () => void;
  act: Function;
  context: any;
}) => {
  const { items, equippedGear, selectedHash, onSelectGear, act, context } = props;
  const [ctxMenu, setCtxMenu] = useLocalState<ContextMenuState | null>(
    context, "gearCtxMenu", null,
  );
  const [collapsedGroups, setCollapsedGroups] = useLocalState<Record<string, boolean>>(
    context, "gearCollapsedGroups", {},
  );

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

  const toggleGroup = (sg: string) => {
    setCollapsedGroups({ ...collapsedGroups, [sg]: !collapsedGroups[sg] });
  };

  return (
    <Box>
      {!!ctxMenu && (
        <GearContextMenu
          menu={ctxMenu}
          act={act}
          onClose={() => setCtxMenu(null)}
        />
      )}
      <Table>
        {groupOrder.flatMap((sg) => [
          ...(sg
            ? [
                <tr key={"header-" + sg}>
                  <td colSpan={4} style={{ padding: 0 }}>
                    <Box
                      className="CharSetup__miscCatHeader"
                      onClick={() => toggleGroup(sg)}
                    >
                      <Box className="CharSetup__miscCatHeader__label">{sg}</Box>
                      <Icon
                        name={collapsedGroups[sg] ? "chevron-right" : "chevron-down"}
                        color="label"
                      />
                    </Box>
                  </td>
                </tr>,
              ]
            : []),
          ...(collapsedGroups[sg] ? [] : groups[sg].map((item) => {
            const isEquipped = equippedGear?.[item.hash];
            const isSelected = selectedHash === item.hash;
            const isLocked = !item.allowed && !isEquipped;
            const isUnavailable = isLocked || (!item.canEquip && !item.price);
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
                    : () => {
                        onSelectGear?.();
                        act("selectGear", { hash: item.hash });
                      }
                }
                onContextMenu={
                  isUnavailable
                    ? undefined
                    : (e: MouseEvent) => {
                        e.preventDefault();
                        setCtxMenu({
                          x: e.clientX,
                          y: e.clientY,
                          item,
                          isEquipped: !!isEquipped,
                        });
                      }
                }
              >
                <Table.Cell collapsing>
                  {item.icon && item.iconState ? (
                    <Box className="CharSetup__gearIcon">
                      <GearSpriteIcon
                        dmiFile={item.icon}
                        state={item.iconState}
                        size={32}
                      />
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
                      : isLocked
                        ? "bad"
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
                <Table.Cell collapsing color="gold">
                  {item.price > 0 && !isEquipped && (
                    <Box inline>
                      <Icon name="coins" mr={0.25} />
                      {item.discount > 0
                        ? Math.round(item.price * item.discount)
                        : item.price}
                    </Box>
                  )}
                </Table.Cell>
              </Table.Row>
            );
          })),
        ])}
      </Table>
    </Box>
  );
};

/** Right-click context menu for gear items */
const GearContextMenu = (props: {
  menu: ContextMenuState;
  act: Function;
  onClose: () => void;
}) => {
  const { menu, act, onClose } = props;
  const { item, isEquipped, x, y } = menu;

  const doAction = (action: string) => {
    act(action, { hash: item.hash });
    onClose();
  };

  return (
    <Box
      className="CharSetup__ctxMenuBackdrop"
      onClick={onClose}
      onContextMenu={(e: MouseEvent) => { e.preventDefault(); onClose(); }}
    >
      <Box
        className="CharSetup__ctxMenu"
        style={{ left: `${x}px`, top: `${y}px` }}
      >
        <Box className="CharSetup__ctxMenuHeader">{item.name}</Box>
        {!!item.canEquip && (
          <Box
            className="CharSetup__ctxMenuItem"
            onClick={() => doAction("toggleGear")}
          >
            <Icon name={isEquipped ? "minus" : "plus"} mr={0.5} />
            {isEquipped ? "Unequip" : "Equip"}
          </Box>
        )}
        {!item.canEquip && item.price > 0 && (
          <Box
            className="CharSetup__ctxMenuItem"
            onClick={() => doAction("buyGear")}
          >
            <Icon name="shopping-cart" mr={0.5} />
            Buy ({item.price} opyxes)
          </Box>
        )}
      </Box>
    </Box>
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
        {detail.tweakedIcon && detail.tweakedIconState && (
          <Stack.Item>
            <Box className="CharSetup__gearDetailIcon">
              <GearSpriteIcon
                dmiFile={detail.tweakedIcon}
                state={detail.tweakedIconState}
                color={detail.tweakedColor || undefined}
                size={32}
              />
            </Box>
          </Stack.Item>
        )}
        <Stack.Item grow>
          <Box bold fontSize="13px">
            {detail.name}
          </Box>
          {detail.slotName && (
            <Box color="label" fontSize="11px">
              {detail.slotName}
              {detail.cost > 0 && ` \u00b7 ${detail.cost} LP`}
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

// FontAwesome icons for body parts
const ORGAN_ICONS: Record<string, string> = {
  head: "skull",
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
                      {selectedOrgan !== "chest" && selectedOrgan !== "head" && selectedOrgan !== "groin" && (
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
  const [showBankDetails, setShowBankDetails] = useLocalState(
    context,
    "showBankDetails",
    false,
  );

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
      {/* Fallback option + Reset All — single row */}
      <Stack.Item>
        <Stack align="center">
          <Stack.Item>
            <Box bold mr={0.5} inline>
              If preferences unavailable:
            </Box>
          </Stack.Item>
          <Stack.Item grow>
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
          </Stack.Item>
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

      {/* Company relation */}
      <Stack.Item>
        <Box bold mb={0.5}>
          <Icon name="building" mr={0.5} />
          {data.company_name} Relation
        </Box>
        <Stack>
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
      </Stack.Item>

      {/* Bank Account */}
      <Stack.Item>
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
      </Stack.Item>

      <Stack.Item>
        <Divider />
      </Stack.Item>

      {/* Job list grouped by department */}
      <Stack.Item grow basis={0} style={{ overflow: "auto" }}>
        <Box className="CharSetup__jobList">
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
                  "background-color": hexToRgba(deptColor, 0.10),
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
                    className={classes([
                      "CharSetup__jobRow",
                      job.head && "CharSetup__jobRow--head",
                    ])}
                    style={{
                      opacity: isAvailable ? 1 : 0.5,
                      ...(job.head ? { "--dept-color-bg": hexToRgba(deptColor, 0.14) } as any : {}),
                    }}
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
                        <Box inline ml={0.5} color="bad" fontSize="11px">
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
        </Box>
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
    "traits" as "traits" | "antag"
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
          <>
            <AntagSubPanel data={data} act={act} />
            <UplinkSubPanel data={data} act={act} />
          </>
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

      {/* Trait records + Myopia */}
      <Box className="CharSetup__medSection">
        <Box className="CharSetup__medSectionHead">
          <Icon name="stethoscope" mr={0.5} />
          {traitCategory.toUpperCase()} ASSESSMENT FINDINGS
        </Box>
        <Box className="CharSetup__medTraitList">
          {/* Myopia — pinned at top of physical findings */}
          {traitCategory === "Physical" && (
            <Box
              className={
                "CharSetup__medTraitRow" +
                (data.disabilities & NEARSIGHTED
                  ? " CharSetup__medTraitRow--active"
                  : "")
              }
              onClick={() => act("toggleDisability", { flag: NEARSIGHTED })}
            >
              <Stack align="flex-start">
                <Stack.Item>
                  <Box
                    className={
                      "CharSetup__medTraitCheck" +
                      (data.disabilities & NEARSIGHTED
                        ? " CharSetup__medTraitCheck--on"
                        : "")
                    }
                  >
                    <Icon
                      name={
                        data.disabilities & NEARSIGHTED
                          ? "check-circle"
                          : "circle"
                      }
                    />
                  </Box>
                </Stack.Item>
                <Stack.Item grow>
                  <Box className="CharSetup__medTraitName">
                    <Icon name="eye-slash" mr={0.5} />
                    Myopia
                    {!!(data.disabilities & NEARSIGHTED) && (
                      <Box as="span" className="CharSetup__medTraitStamp">
                        DOCUMENTED
                      </Box>
                    )}
                  </Box>
                  <Box className="CharSetup__medTraitDesc">
                    Subject requires corrective lenses for standard visual acuity.
                  </Box>
                </Stack.Item>
              </Stack>
            </Box>
          )}
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
  { id: "records", label: "Records", icon: "file-medical" },
  { id: "flavor", label: "Flavor", icon: "feather-alt" },
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
    "records",
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
  Neutral: "default",
  Skeptical: "orange",
  Opposed: "red",
};

// --- Languages: compact section for ID card back ---

const LanguagesCompact = (props: {
  data: CharacterData;
  act: Function;
}) => {
  const { data, act } = props;
  const langInfo = data.species_languages?.[data.species];
  const altLangs = data.alternate_languages || [];

  return (
    <Box>
      <Box className="CharSetup__idCardBackLabel">Languages</Box>

      {/* Native language row */}
      {langInfo?.native && (
        <Box className="CharSetup__langRow">
          <Icon name="star" className="CharSetup__langIcon CharSetup__langIcon--native" />
          <Box className="CharSetup__langName">{langInfo.native}</Box>
          <Box className="CharSetup__langTag CharSetup__langTag--native">native</Box>
        </Box>
      )}

      {/* Default language row (if different from native) */}
      {langInfo?.default && langInfo.default !== langInfo.native && (
        <Box className="CharSetup__langRow">
          <Icon name="comment" className="CharSetup__langIcon" />
          <Box className="CharSetup__langName">{langInfo.default}</Box>
          <Box className="CharSetup__langTag">default</Box>
        </Box>
      )}

      {/* Secondary language rows */}
      {altLangs.map((lang) => (
        <Box key={lang} className="CharSetup__langRow">
          <Icon name="plus" className="CharSetup__langIcon CharSetup__langIcon--alt" />
          <Box className="CharSetup__langName">{lang}</Box>
          <CsButton
            icon="times"
            compact
            color="danger"
            tooltip="Remove"
            onClick={() => act("removeLanguage", { language: lang })}
          />
        </Box>
      ))}

      {/* Add language dropdown */}
      {langInfo && langInfo.max_alternates > 0 &&
        altLangs.length < langInfo.max_alternates && (
          <Dropdown
            fluid
            mt={0.25}
            displayText={`+ Add language (${altLangs.length}/${langInfo.max_alternates})`}
            options={(langInfo.available || []).filter(
              (l) => !altLangs.includes(l),
            )}
            onSelected={(val: string) =>
              act("addLanguage", { language: val })
            }
          />
        )}
    </Box>
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

      {RECORD_DEFS.map((rec) => {
        const value = RECORD_VALUES[rec.key](data);
        const hasContent = !!value;

        return (
          <Box key={rec.key} mb={0.5}>
            <Box className="CharSetup__card">
              <Stack align="center">
                <Stack.Item>
                  <Box inline className="CharSetup__cardIcon" color={rec.color}>
                    <Icon name={rec.icon} />
                  </Box>
                </Stack.Item>
                <Stack.Item grow ml={0.75}>
                  <Box bold>{rec.label}</Box>
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
                  <Button
                    icon="pen"
                    compact
                    onClick={() => act("editRecordFancy", { type: rec.key })}
                  >
                    {hasContent ? "Edit..." : "Write..."}
                  </Button>
                </Stack.Item>
              </Stack>
            </Box>
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
                <Box inline ml={1} fontSize="11px" color="label">
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
            <Box fontSize="11px" color="label">
              What all connections know about you
            </Box>
          </Stack.Item>
          <Stack.Item>
            <CsButton
              icon={editingInfo === "general" ? "check" : "pen"}
              compact
              tooltip={editingInfo === "general" ? "Save" : "Edit"}
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
                <Box fontSize="11px" color="label" italic>
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
                    <Box fontSize="11px" color="label">
                      <Icon name="comment-dots" mr={0.25} />
                      {" Personal note for this connection:"}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <CsButton
                      icon={isEditingThis ? "check" : "pen"}
                      compact
                      tooltip={isEditingThis ? "Save" : "Edit note"}
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
                    fontSize="11px"
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

// --- HUD UI preview with theme/color/alpha controls ---

const UiPreviewCard = (props: {
  data: CharacterData;
  act: Function;
  context: any;
}) => {
  const { data, act, context } = props;

  const [style, setStyle] = useLocalState(context, "uiPrevStyle", data.ui_style || "Goon");
  const [alpha, setAlpha] = useLocalState(context, "uiPrevAlpha",
    (data.ui_style_alpha ?? 255) / 255);

  const hexColor = data.ui_style_color || "#ffffff";
  const themeImg = UI_THEME_IMAGE[style] || uiGoon;

  const [hudExpanded, setHudExpanded] = useLocalState(
    context, "hudPreviewExpanded", false);

  return (
    <Box mb={0.5}>
      <Box
        className={classes([
          "CharSetup__card",
          "CharSetup__card--expandable",
          "CharSetup__card--accentLeft",
          hudExpanded && "CharSetup__card--expanded",
        ])}
        style={{ "--cs-card-accent": "#82aaff" }}
        onClick={() => setHudExpanded(!hudExpanded)}
      >
        <Stack align="center">
          <Stack.Item>
            <Box inline className="CharSetup__cardIcon" color="#82aaff">
              <Icon name="desktop" />
            </Box>
          </Stack.Item>
          <Stack.Item grow ml={0.5}>
            <Box bold>HUD Customization</Box>
          </Stack.Item>
          <Stack.Item>
            <Icon
              name={hudExpanded ? "chevron-up" : "chevron-down"}
              color="label"
            />
          </Stack.Item>
        </Stack>
      </Box>
      {hudExpanded && (
      <Box className="CharSetup__cardBody">
        <Stack>
          {/* Preview — left, fills available space */}
          <Stack.Item grow basis={0}>
            <Box className="CharSetup__uiPreview">
              <img
                className="CharSetup__uiPreviewBg"
                src={uiPreviewBg}
              />
              <svg
                className="CharSetup__uiPreviewHud"
                xmlns="http://www.w3.org/2000/svg"
                version="1.1"
              >
                <defs>
                  <filter id="uiColorMask">
                    <feFlood floodColor={hexColor} result="flood" />
                    <feComposite
                      in="SourceGraphic"
                      in2="flood"
                      operator="arithmetic"
                      k1="1"
                      k2="0"
                      k3="0"
                      k4="0"
                    />
                  </filter>
                </defs>
                <image
                  opacity={alpha}
                  width="100%"
                  height="100%"
                  preserveAspectRatio="xMaxYMax slice"
                  xlinkHref={themeImg}
                  filter="url(#uiColorMask)"
                />
              </svg>
              <img
                className="CharSetup__uiPreviewItems"
                src={uiPreviewItems}
              />
            </Box>
          </Stack.Item>
          {/* Controls — right sidebar */}
          <Stack.Item ml={0.5}>
            <Stack vertical>
              <Stack.Item mb={0.5}>
                <Box bold fontSize="11px" mb={0.2}>Theme</Box>
                <Dropdown
                  selected={style}
                  options={data.ui_themes || []}
                  onSelected={(v: string) => setStyle(v)}
                  width="9rem"
                />
              </Stack.Item>
              <Stack.Item mb={0.5}>
                <Box bold fontSize="11px" mb={0.2}>Color</Box>
                <Box
                  className="CharSetup__colorSwatch"
                  style={{ backgroundColor: hexColor }}
                  onClick={() => act("pickUiColor")}
                />
              </Stack.Item>
              <Stack.Item mb={0.5}>
                <Box bold fontSize="11px" mb={0.2}>Alpha</Box>
                <NumberInput
                  value={alpha}
                  minValue={0.0}
                  maxValue={1.0}
                  step={0.05}
                  stepPixelSize={10}
                  width="4rem"
                  onDrag={(_, v) => setAlpha(v)}
                  format={(v) => v.toFixed(2)}
                />
              </Stack.Item>
              <Stack.Item>
                <CsButton
                  fluid
                  icon="check"
                  onClick={() =>
                    act("setUiStyle", {
                      style,
                      alpha: Math.round(alpha * 255),
                    })
                  }
                >
                  Apply
                </CsButton>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Box>
      )}
    </Box>
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
  // Sort categories by display order (computed before state init so we can default to first)
  const sortedCats = PREF_CATEGORY_ORDER.filter((c) => c in categories);
  for (const cat of Object.keys(categories)) {
    if (!sortedCats.includes(cat)) {
      sortedCats.push(cat);
    }
  }

  const visibleCats = sortedCats.filter((c) => (categories[c] || []).length > 0);

  const [expandedCat, setExpandedCat] = useLocalState<string | null>(
    context,
    "prefExpandedCat",
    visibleCats[0] ?? null,
  );

  return (
    <>
      <UiPreviewCard data={data} act={act} context={context} />
      {visibleCats.map((catName) => {
        const prefs = categories[catName] || [];
        const meta = PREF_CATEGORY_META[catName] || {
          icon: "cog",
          color: "#999",
        };
        const isExpanded = expandedCat === catName;

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
                setExpandedCat(isExpanded ? null : catName)
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
                    fontSize="11px"
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

// Sorted longest-first to avoid substring collisions (e.g. "North" before "Northwest")
const BYOND_KEY_SORTED = Object.entries(BYOND_KEY_DISPLAY).sort(
  (a, b) => b[0].length - a[0].length,
);

const displayKey = (key: string): string => {
  let result = key;
  for (const [byond, display] of BYOND_KEY_SORTED) {
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
  kbSearch: string;
}> {
  keyHandler: ((e: KeyboardEvent) => void) | null;

  constructor(props) {
    super(props);
    this.state = {
      expandedKbCat: null,
      capturingBinding: null,
      capturingOldKey: null,
      kbSearch: "",
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
    const { data, act, context } = this.props;
    const { expandedKbCat, capturingBinding, kbSearch } = this.state;
    const kbCategories = data.keybinding_categories || {};
    const userBinds = data.user_keybindings || {};

    const setKbSearch = (v: string) => this.setState({ kbSearch: v });

    // Sort categories
    const sortedCats = KB_CATEGORY_ORDER.filter((c) => c in kbCategories);
    for (const cat of Object.keys(kbCategories)) {
      if (!sortedCats.includes(cat)) {
        sortedCats.push(cat);
      }
    }

    const isCapturing = capturingBinding !== null;
    const searchLower = kbSearch.trim().toLowerCase();

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

        {/* Search */}
        <Box mb={0.75}>
          <Input
            fluid
            placeholder="Search keybindings..."
            value={kbSearch}
            onInput={(_, value) => setKbSearch(value)}
          />
        </Box>

        {sortedCats.filter((catName) => (kbCategories[catName] || []).length > 0).map((catName) => {

          const allBindings = kbCategories[catName] || [];
          const bindings = searchLower
            ? allBindings.filter((kb) =>
                kb.full_name.toLowerCase().includes(searchLower)
                || (kb.description && kb.description.toLowerCase().includes(searchLower)))
            : allBindings;
          if (bindings.length === 0) return null;
          const isExpanded = expandedKbCat === catName || !!searchLower;
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
                    <Box inline fontSize="11px" color="label" mr={0.5}>
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
                              <Box fontSize="11px" color="label">
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
