import { useBackend, useLocalState } from "../backend";
import { Divider, Flex, Input, Section, Table, Button } from "../components";
import { ButtonCheckbox } from "../components/Button";
import { Window } from "../layouts";

type Target = {
  name: string;
  position: [number, number, number];
  area: string;
  isMob: boolean;
  isGhost: boolean;
  hasClient: boolean;
  ckey?: string;
  ref: string;
};

type InputData = {
  targets: Target[];
};

type FilterState = "exclude" | "none" | "include";

function TargetStatus(props: { target: Target }, context: any) {
  const { isMob, isGhost, hasClient } = props.target;

  return (
    <>
      {hasClient ? <i style="margin-right: 4px;" class="fas fa-user"></i> : ""}
      {isMob ? <i class="fas fa-paw"></i> : <i class="fas fa-cube"></i>}
      {isGhost ? <i style="margin-left: 4px;" class="fas fa-ghost"></i> : ""}
    </>
  );
}

function FilterButton(
  props: {
    state: FilterState;
    name: string;
    onClick: (newState: boolean) => void;
  },
  context: any
) {
  let icon: string;

  if (props.state === "include") {
    icon = "plus-square-o";
  } else if (props.state === "exclude") {
    icon = "minus-square-o";
  } else {
    icon = "square-o";
  }

  return (
    <Button icon={icon} onClick={props.onClick}>
      {props.name}
    </Button>
  );
}

function nextFilterState(current: FilterState): FilterState {
  if (current === "include") {
    return "exclude";
  } else if (current === "exclude") {
    return "none";
  } else {
    return "include";
  }
}

export function FollowPanel(props: any, context: any) {
  const { getTheme, data, act } = useBackend<InputData>(context);

  const [ghostFilter, setGhostFilter] = useLocalState<FilterState>(
    context,
    "ghostFilter",
    "none"
  );

  const [clientFilter, setClientFilter] = useLocalState<FilterState>(
    context,
    "clientFilter",
    "none"
  );

  const [mobFilter, setMobFilter] = useLocalState<FilterState>(
    context,
    "mobFilter",
    "none"
  );

  let result = data.targets.filter((t, _) => {
    let f = true;

    f =
      ((clientFilter === "include" && t.hasClient) ||
        (clientFilter === "exclude" && !t.hasClient) ||
        (clientFilter === "none" && f)) &&
      f;
    f =
      ((mobFilter === "include" && t.isMob) ||
        (mobFilter === "exclude" && !t.isMob) ||
        (mobFilter === "none" && f)) &&
      f;
    f =
      ((ghostFilter === "include" && t.isGhost) ||
        (ghostFilter === "exclude" && !t.isGhost) ||
        (ghostFilter === "none" && f)) &&
      f;

    return f;
  });

  return (
    <Window theme={getTheme("neutral")} width={700} height={800}>
      <Window.Content scrollable>
        <Flex direction="column">
          <Section title="Filters">
            <FilterButton
              name="Ghosts"
              state={ghostFilter}
              onClick={() => setGhostFilter(nextFilterState(ghostFilter))}
            />
            <FilterButton
              name="Client"
              state={clientFilter}
              onClick={() => setClientFilter(nextFilterState(clientFilter))}
            />
            <FilterButton
              name="Mob"
              state={mobFilter}
              onClick={() => setMobFilter(nextFilterState(mobFilter))}
            />
          </Section>
          <Table>
            <Table.Row>
              <Table.Cell color="label" textAlign="center" bold>
                Jump
              </Table.Cell>
              <Table.Cell color="label" textAlign="center" bold>
                Type
              </Table.Cell>
              <Table.Cell color="label" textAlign="center" bold>
                Position
              </Table.Cell>
              <Table.Cell color="label" bold>
                Name
              </Table.Cell>
              <Table.Cell color="label" bold>
                Area
              </Table.Cell>
            </Table.Row>
            {result.map((t) => {
              return (
                <Table.Row>
                  <Table.Cell width="1px" textAlign="center">
                    <Button
                      onClick={() => act("follow", { ref: t.ref })}
                      icon="fas fa-map-marker"
                    />
                  </Table.Cell>
                  <Table.Cell textAlign="center">
                    {<TargetStatus target={t} />}
                  </Table.Cell>
                  <Table.Cell textAlign="center">
                    {`${t.position[0]}, ${t.position[1]}, ${t.position[2]}`}
                  </Table.Cell>
                  <Table.Cell>
                    {t.name}
                    {t.ckey ? ` (${t.ckey})` : ""}
                  </Table.Cell>
                  <Table.Cell>{t.area} </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Flex>
      </Window.Content>
    </Window>
  );
}
