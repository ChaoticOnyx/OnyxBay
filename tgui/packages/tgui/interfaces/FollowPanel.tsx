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

export function FollowPanel(props: any, context: any) {
  const { getTheme, data, act } = useBackend<InputData>(context);

  const [ghostFilter, setGhostFilter] = useLocalState(
    context,
    "ghostFilter",
    false
  );

  const [clientFilter, setClientFilter] = useLocalState(
    context,
    "clientFilter",
    true
  );

  const [mobFilter, setMobFilter] = useLocalState(context, "mobFilter", true);
  const [objectFilter, setObjectFilter] = useLocalState(
    context,
    "objectFilter",
    false
  );

  let result = data.targets.filter((t, _) => {
    let f = false;

    f = f || (clientFilter && t.hasClient);
    f = f || (mobFilter && t.isMob);
    f = f || (objectFilter && !t.isMob);

    if (!ghostFilter && t.isGhost) {
      f = false;
    }

    return f;
  });

  return (
    <Window theme={getTheme("neutral")} width={700} height={800}>
      <Window.Content scrollable>
        <Flex direction="column">
          <Section title="Filters">
            <ButtonCheckbox
              onClick={() => setGhostFilter(!ghostFilter)}
              checked={ghostFilter}
            >
              Include Ghosts
            </ButtonCheckbox>
            <ButtonCheckbox
              onClick={() => setClientFilter(!clientFilter)}
              checked={clientFilter}
            >
              Client
            </ButtonCheckbox>
            <ButtonCheckbox
              onClick={() => setMobFilter(!mobFilter)}
              checked={mobFilter}
            >
              Mob
            </ButtonCheckbox>
            <ButtonCheckbox
              onClick={() => setObjectFilter(!objectFilter)}
              checked={objectFilter}
            >
              Object
            </ButtonCheckbox>
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
