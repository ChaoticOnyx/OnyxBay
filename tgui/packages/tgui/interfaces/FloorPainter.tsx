/* eslint-disable camelcase */
import { useBackend } from "../backend";
import { Button, ColorBox, Divider, Stack } from "../components";
import { GameIcon } from "../components/GameIcon";
import { Window } from "../layouts";

interface Settings {
  paint_colour: string;
  paint_dir: string;
  decal: string;
}

interface Decal {
  name: string;
  icon: string;
  path: string;
  coloured: boolean;
  precise: boolean;
}

const Directions = {
  north: 180,
  northwest: 145,
  west: 90,
  southwest: 45,
  south: 0,
  southeast: 315,
  east: 270,
  northeast: 225,
  precise: 0,
};

interface InputData {
  settings: Settings;
  decals: Decal[];
}

const decalButton = (decal: Decal, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { settings, decals } = data;
  const selectedDecal = decals.find((d) => d.path === settings.decal);

  return (
    <Button
      className="FloorPainter__Button"
      onClick={() => act("set_decal", { path: decal.path })}
      tooltip={decal.name}
      selected={decal.name === selectedDecal.name}
    >
      <GameIcon html={decal.icon} />
    </Button>
  );
};

const directionButtons = (context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { settings, decals } = data;
  const { paint_dir } = settings;
  const selectedDecal = decals.find((d) => d.path === settings.decal);

  return (
    <Stack vertical>
      <Stack.Item>
        <Button
          className="FloorPainter__Button"
          iconRotation={-45}
          icon="arrow-up"
          selected={paint_dir === "northwest"}
          onClick={() => act("set_direction", { direction: "northwest" })}
        />
        <Button
          className="FloorPainter__Button"
          icon="arrow-up"
          selected={paint_dir === "north"}
          onClick={() => act("set_direction", { direction: "north" })}
        />
        <Button
          className="FloorPainter__Button"
          iconRotation={45}
          icon="arrow-up"
          selected={paint_dir === "northeast"}
          onClick={() => act("set_direction", { direction: "northeast" })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          className="FloorPainter__Button"
          icon="arrow-left"
          selected={paint_dir === "west"}
          onClick={() => act("set_direction", { direction: "west" })}
        />
        <Button
          className="FloorPainter__Button"
          icon="circle-o"
          disabled={!selectedDecal.precise}
          selected={paint_dir === "precise"}
          onClick={() => act("set_direction", { direction: "precise" })}
        />
        <Button
          className="FloorPainter__Button"
          icon="arrow-right"
          selected={paint_dir === "east"}
          onClick={() => act("set_direction", { direction: "east" })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          className="FloorPainter__Button"
          iconRotation={45}
          icon="arrow-down"
          selected={paint_dir === "southwest"}
          onClick={() => act("set_direction", { direction: "southwest" })}
        />
        <Button
          className="FloorPainter__Button"
          icon="arrow-down"
          selected={paint_dir === "south"}
          onClick={() => act("set_direction", { direction: "south" })}
        />
        <Button
          className="FloorPainter__Button"
          iconRotation={-45}
          icon="arrow-down"
          selected={paint_dir === "southeast"}
          onClick={() => act("set_direction", { direction: "southeast" })}
        />
      </Stack.Item>
    </Stack>
  );
};

export const FloorPainter = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { settings, decals } = data;
  const selectedDecal = decals.find((d) => d.path === settings.decal);

  return (
    <Window width={300} height={340}>
      <Window.Content>
        <Stack width="100%" justify="space-between">
          <Stack.Item>{directionButtons(context)}</Stack.Item>
          <Stack.Item>
            <Stack vertical justify="space-between" textAlign="center" fill>
              <Stack.Item>
                <GameIcon
                  style={{
                    transform: `rotate(${Directions[settings.paint_dir]}deg)`,
                  }}
                  html={selectedDecal.icon}
                />
              </Stack.Item>
              <Stack.Item>
                <ColorBox color={settings.paint_colour} />{" "}
                {settings.paint_colour}
              </Stack.Item>
              <Stack.Item>
                <Button
                  className="FloorPainter__Button"
                  onClick={() => act("choose_color")}
                  disabled={!selectedDecal.coloured}
                  icon="eye-dropper"
                  content="Pick"
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
        <Divider />
        {decals.map((decal) => {
          return decalButton(decal, context);
        })}
      </Window.Content>
    </Window>
  );
};
