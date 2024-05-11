import { classes } from "common/react";
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Flex, Icon, Input, Stack } from "../components";
import { Window } from "../layouts";
import { groupBy } from "common/collections";

type Atom = {
  type: string;
  name: string;
  icon: string | null;
  ref: string;
};

type Data = {
  atoms: Atom[];
};

export const TurfExamine = (props: any, context: any) => {
  const { act, data } = useBackend<Data>(context);
  const { atoms } = data;

  const [stacking, setStacking] = useLocalState<boolean>(
    context,
    "stacking",
    true
  );
  const [search, setSearch] = useLocalState<string>(context, "search", "");

  const filteredAtoms = atoms.filter((atom: Atom) =>
    atom.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Window width={250} height={275} title="Examine">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder="Serach on turf..."
                  onChange={(_, value: string) => setSearch(value)}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="layer-group"
                  tooltip={`${
                    stacking ? "Disable" : "Enable"
                  } duplicate stacking`}
                  selected={stacking}
                  onClick={() => setStacking(!stacking)}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="rotate-right"
                  tooltip="Refresh"
                  onClick={() => act("refresh")}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow overflowY="scroll">
            <AtomList stacked={stacking} atoms={filteredAtoms} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type AtomListProps = {
  stacked: boolean;
  atoms: Atom[];
};

const AtomList = (props: AtomListProps, context: any) => {
  const { stacked, atoms } = props;

  const onClickHandler = (ref: string) => (event: MouseEvent) => {
    event.preventDefault();
    let clickCatcher = `?src=${ref}`;

    switch (event.button) {
      case 1:
        clickCatcher += ";panel_click=middle";
        break;
      case 2:
        clickCatcher += ";panel_click=right";
        break;
      default:
        clickCatcher += ";panel_click=left";
    }

    if (event.shiftKey) {
      clickCatcher += ";panel_shiftclick=1";
    }
    if (event.ctrlKey) {
      clickCatcher += ";panel_ctrlclick=1";
    }
    if (event.altKey) {
      clickCatcher += ";panel_altclick=1";
    }

    window.location.href = clickCatcher;
  };

  return (
    <Flex ml={1} direction="row" align="start" wrap="wrap">
      {(stacked &&
        Array.from(groupBy((atom: Atom) => atom.type)(atoms)).map(
          ([_, atoms], index) => {
            return (
              <Flex.Item key={index}>
                <AtomDisplay
                  atom={atoms[0]}
                  count={atoms.length}
                  onClick={onClickHandler(atoms[0].ref)}
                />
              </Flex.Item>
            );
          }
        )) ||
        atoms.map((atom: Atom, index: number) => (
          <Flex.Item key={index}>
            <AtomDisplay atom={atom} onClick={onClickHandler(atom.ref)} />
          </Flex.Item>
        ))}
    </Flex>
  );
};

type AtomDisplayProps = {
  atom: Atom;
  count?: number;
  onClick: (event: Event) => void;
};

const AtomDisplay = (props: AtomDisplayProps, context: any) => {
  const { atom, count, onClick } = props;

  return (
    <Flex
      direction="column"
      className={classes(["TurfExamine", "TurfExamine__Card"])}
      onClick={onClick}
    >
      <Flex.Item grow className="TurfExamine__Image">
        {(!atom.icon && (
          <Box height="32px" className="TurfExamine__Image--error">
            <Icon color="label" name="circle-question" />
          </Box>
        )) || <img width="32px" height="32px" src={atom.icon} />}
        {!!count && count > 1 && (
          <Box className="TurfExamine__Count">{count}</Box>
        )}
      </Flex.Item>
      <Flex.Item grow className="TurfExamine__Label">
        {atom.name}
      </Flex.Item>
    </Flex>
  );
};
