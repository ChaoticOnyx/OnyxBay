import { filter, sortBy } from "common/collections";
import { flow } from "common/fp";
import { multiline } from "common/string";
import { useBackend, useLocalState } from "tgui/backend";
import {
  Button,
  Collapsible,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from "tgui/components";
import { Window } from "tgui/layouts";

import { JOB2ICON } from "./common/JobToIcon";

const ANTAG2COLOR = {
  "Ash Walkers": "olive",
  "Bounty Hunters": "yellow",
  CentCom: "teal",
  "Digital Anomalies": "teal",
  "Emergency Response Team": "teal",
  "Escaped Fugitives": "orange",
  Xenomorph: "violet",
  "Spacetime Aberrations": "white",
  "Deviant Crew": "white",
} as const;

const THREAT = {
  Low: 1,
  Medium: 5,
  High: 8,
} as const;

const HEALTH = {
  Good: 99, // nice
  Average: 19,
} as const;

type Antagonist = Observable & { antag: string; antag_group: string };

type AntagGroup = [string, Antagonist[]];

type OrbitData = {
  alive: Observable[];
  antagonists: Antagonist[];
  dead: Observable[];
  deadchat_controlled: Observable[];
  ghosts: Observable[];
  misc: Observable[];
  npcs: Observable[];
};

type Observable = {
  extra?: string;
  full_name: string;
  health?: number;
  job?: string;
  name?: string;
  orbiters?: number;
  ref: string;
};

/** Controls filtering out the list of observables via search */
const ObservableSearch = (props: any, context: any) => {
  const { act, data } = useBackend<OrbitData>(context);
  const {
    alive = [],
    antagonists = [],
    deadchat_controlled = [],
    dead = [],
    ghosts = [],
    misc = [],
    npcs = [],
  } = data;

  const [autoObserve, setAutoObserve] = useLocalState<boolean>(
    context,
    "autoObserve",
    false
  );
  const [heatMap, setHeatMap] = useLocalState<boolean>(
    context,
    "heatMap",
    false
  );
  const [searchQuery, setSearchQuery] = useLocalState<string>(
    context,
    "searchQuery",
    ""
  );

  /** Gets a list of Observables, then filters the most relevant to orbit */
  const orbitMostRelevant = (searchQuery: string) => {
    const mostRelevant = getMostRelevant(searchQuery, [
      alive,
      antagonists,
      deadchat_controlled,
      dead,
      ghosts,
      misc,
      npcs,
    ]);

    if (mostRelevant !== undefined) {
      act("orbit", {
        ref: mostRelevant.ref,
      });
    }
  };

  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Icon name="search" />
        </Stack.Item>
        <Stack.Item grow>
          <Input
            autoFocus
            fluid
            onEnter={(event, value) => orbitMostRelevant(value)}
            onInput={(event, value) => setSearchQuery(value)}
            placeholder="Search..."
            value={searchQuery}
          />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Button
            color="transparent"
            icon={!heatMap ? "heart" : "ghost"}
            onClick={() => setHeatMap(!heatMap)}
            tooltip={multiline`Toggles between highlighting health or
            orbiters.`}
            tooltipPosition="bottom-start"
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            color="transparent"
            icon="sync-alt"
            onClick={() => act("refresh")}
            tooltip="Refresh"
            tooltipPosition="bottom-start"
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
export const Orbit = (props: any, context: any) => {
  return (
    <Window title="Orbit" width={400} height={550}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <ObservableSearch />
          </Stack.Item>
          <Stack.Item mt={0.2} grow>
            <Section fill>
              <ObservableContent />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/**
 * The primary content display for points of interest.
 * Renders a scrollable section replete with subsections for each
 * observable group.
 */
const ObservableContent = (props: any, context: any) => {
  const { data } = useBackend<OrbitData>(context);
  const {
    alive = [],
    antagonists = [],
    deadchat_controlled = [],
    dead = [],
    ghosts = [],
    misc = [],
    npcs = [],
  } = data;

  let collatedAntagonists: AntagGroup[] = [];

  if (antagonists.length) {
    collatedAntagonists = getAntagCategories(antagonists);
  }

  return (
    <Stack vertical>
      {collatedAntagonists?.map(([title, antagonists]) => {
        return (
          <ObservableSection
            color={ANTAG2COLOR[title] || "bad"}
            key={title}
            section={antagonists}
            title={title}
          />
        );
      })}
      <ObservableSection
        color="purple"
        section={deadchat_controlled}
        title="Deadchat Controlled"
      />
      <ObservableSection color="blue" section={alive} title="Alive" />
      <ObservableSection section={dead} title="Dead" />
      <ObservableSection section={ghosts} title="Ghosts" />
      <ObservableSection section={misc} title="Misc" />
      <ObservableSection section={npcs} title="NPCs" />
    </Stack>
  );
};

/**
 * Displays a collapsible with a map of observable items.
 * Filters the results if there is a provided search query.
 */
const ObservableSection = (props: any, context: any) => {
  const { color, section = [], title } = props;

  if (!section.length) {
    return null;
  }

  const [searchQuery] = useLocalState<string>(context, "searchQuery", "");

  const filteredSection: Observable[] = flow([
    filter((observable) => isJobOrNameMatch(observable, searchQuery)),
    sortBy((observable) =>
      getDisplayName(observable.full_name, observable.name)
        .replace(/^"/, "")
        .toLowerCase()
    ),
  ])(section);

  if (!filteredSection.length) {
    return null;
  }

  return (
    <Stack.Item>
      <Collapsible
        bold
        color={color ?? "grey"}
        open={!!color}
        title={title + ` - (${filteredSection.length})`}
      >
        {filteredSection.map((poi, index) => {
          return <ObservableItem color={color} item={poi} key={index} />;
        })}
      </Collapsible>
    </Stack.Item>
  );
};

/** Renders an observable button that has tooltip info for living Observables*/
const ObservableItem = (
  props: { color?: string; item: Observable },
  context: any
) => {
  const { act } = useBackend<OrbitData>(context);
  const { color, item } = props;
  const { extra, full_name, job, health, name, orbiters, ref } = item;

  const [autoObserve] = useLocalState<boolean>(context, "autoObserve", false);
  const [heatMap] = useLocalState<boolean>(context, "heatMap", false);

  return (
    <Button
      color={getDisplayColor(item, heatMap, color)}
      icon={(job && JOB2ICON[job]) || null}
      onClick={() => act("orbit", { auto_observe: autoObserve, ref: ref })}
      tooltip={(!!health || !!extra) && <ObservableTooltip item={item} />}
      tooltipPosition="bottom-start"
    >
      {getDisplayName(full_name, name)}
      {!!orbiters && (
        <>
          {" "}
          <Icon mr={0} name={"ghost"} />
          {orbiters}
        </>
      )}
    </Button>
  );
};

/** Displays some info on the mob as a tooltip. */
const ObservableTooltip = (
  props: { item: Observable | Antagonist },
  context: any
) => {
  const { item } = props;
  const { extra, full_name, health, job } = item;
  let antag;
  if ("antag" in item) {
    antag = item.antag;
  }

  const extraInfo = extra?.split(":");
  const displayHealth = !!health && health >= 0 ? `${health}%` : "Critical";

  return (
    <>
      <NoticeBox textAlign="center" nowrap>
        Last Known Data
      </NoticeBox>
      <LabeledList>
        {extraInfo ? (
          <LabeledList.Item label={extraInfo[0]}>
            {extraInfo[1]}
          </LabeledList.Item>
        ) : (
          <>
            {!!full_name && (
              <LabeledList.Item label="Real ID">{full_name}</LabeledList.Item>
            )}
            {!!job && !antag && (
              <LabeledList.Item label="Job">{job}</LabeledList.Item>
            )}
            {!!antag && (
              <LabeledList.Item label="Threat">{antag}</LabeledList.Item>
            )}
            {!!health && (
              <LabeledList.Item label="Health">
                {displayHealth}
              </LabeledList.Item>
            )}
          </>
        )}
      </LabeledList>
    </>
  );
};

/** Return a map of strings with each antag in its antag_category */
const getAntagCategories = (antagonists: Antagonist[]) => {
  const categories: Record<string, Antagonist[]> = {};

  antagonists.map((player) => {
    const { antag_group } = player;

    if (!categories[antag_group]) {
      categories[antag_group] = [];
    }

    categories[antag_group].push(player);
  });

  return sortBy(([key]) => key)(Object.entries(categories));
};

/** Returns a disguised name in case the person is wearing someone else's ID */
const getDisplayName = (full_name: string, name?: string) => {
  if (!name) {
    return full_name;
  }

  if (
    !full_name?.includes("[") ||
    full_name.match(/\(as /) ||
    full_name.match(/^Unknown/)
  ) {
    return name;
  }

  // return only the name before the first ' [' or ' ('
  return `"${full_name.split(/ \[| \(/)[0]}"`;
};

const getMostRelevant = (
  searchQuery: string,
  observables: Observable[][]
): Observable => {
  return flow([
    // Filters out anything that doesn't match search
    filter((observable) => isJobOrNameMatch(observable, searchQuery)),
    // Sorts descending by orbiters
    sortBy((observable) => -(observable.orbiters || 0)),
    // Makes a single Observables list for an easy search
  ])(observables.flat())[0];
};

/** Returns the display color for certain health percentages */
const getHealthColor = (health: number) => {
  switch (true) {
    case health > HEALTH.Good:
      return "good";
    case health > HEALTH.Average:
      return "average";
    default:
      return "bad";
  }
};

/** Returns the display color based on orbiter numbers */
const getThreatColor = (orbiters = 0) => {
  switch (true) {
    case orbiters > THREAT.High:
      return "violet";
    case orbiters > THREAT.Medium:
      return "blue";
    case orbiters > THREAT.Low:
      return "teal";
    default:
      return "good";
  }
};

/** Displays color for buttons based on the health or orbiter count. */
const getDisplayColor = (
  item: Observable,
  heatMap: boolean,
  color?: string
) => {
  const { health, orbiters } = item;
  if (typeof health !== "number") {
    return color ? "good" : "grey";
  }
  if (heatMap) {
    return getThreatColor(orbiters);
  }
  return getHealthColor(health);
};

/** Checks if a full name or job title matches the search. */
const isJobOrNameMatch = (observable: Observable, searchQuery: string) => {
  if (!searchQuery) {
    return true;
  }
  const { full_name, job } = observable;

  return (
    full_name?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    job?.toLowerCase().includes(searchQuery?.toLowerCase()) ||
    false
  );
};
