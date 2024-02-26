import { BooleanLike } from "common/react";
import { Window } from "../layouts";
import { useBackend } from "../backend";
import {
  Box,
  Button,
  Flex,
  Icon,
  Modal,
  NoticeBox,
  Stack,
} from "../components";
import { toTitleCase } from "common/string";

interface Data {
  isLocked: BooleanLike;
  canToggleSafety: BooleanLike;
  isSafetyDisabled: BooleanLike;
  isGravityDisabled: BooleanLike;
  currentProgram: string;
  programs: Program[];
  emag_programs: Program[];
}

interface Program {
  id: string;
  name: string;
}

export const Holodeck = (props: any, context: any) => {
  const { act, data } = useBackend<Data>(context);
  const {
    isLocked,
    canToggleSafety,
    isSafetyDisabled,
    isGravityDisabled,
    currentProgram,
    programs,
  } = data;

  return (
    <Window width={400} height={500} title="Holodeck Controls">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item mb={2}>
            <Stack nowrap justify="space-around">
              <Stack.Item>
                <HolodeckButton
                  icon={isSafetyDisabled ? "skull" : "shield"}
                  desc={`Safety protocols are ${
                    isSafetyDisabled ? "disabled" : "enabled"
                  }.`}
                  selected={!isSafetyDisabled}
                  disabled={!canToggleSafety}
                  onClick={() => act("toggleSafety")}
                />
              </Stack.Item>
              <Stack.Item>
                <HolodeckButton
                  icon={isGravityDisabled ? "feather" : "weight-hanging"}
                  desc={`Gravitation field is ${
                    isGravityDisabled ? "disabled" : "enabled"
                  }.`}
                  selected={!isGravityDisabled}
                  onClick={() => act("toggleGravity")}
                />
              </Stack.Item>
              <Stack.Item>
                <HolodeckButton
                  icon={isLocked ? "lock" : "lock-open"}
                  desc={`Controls are ${isLocked ? "locked" : "unlocked"}.`}
                  selected={!!isLocked}
                  onClick={() => act("toggleLock")}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow mb={1.25} overflowY="scroll">
            <Stack fill vertical>
              {programs.length > 0 ? (
                programs.map((program, index) => (
                  <Stack.Item key={index} mr={1}>
                    <Button
                      fluid
                      selected={currentProgram == program.id}
                      content={toTitleCase(program.name)}
                      onClick={() => act("changeProgram", { id: program.id })}
                    />
                  </Stack.Item>
                ))
              ) : (
                <NoticeBox>No suitable programs found.</NoticeBox>
              )}
            </Stack>
          </Stack.Item>
        </Stack>
        {isLocked ? (
          <Modal
            width={26}
            style={{
              display: "flex",
              "align-items": "center",
              "justify-content": "center",
              "border-radius": "0.5rem",
            }}
          >
            <Stack fill vertical width="100%">
              <Stack.Item grow>
                <NoticeBox danger>
                  Holodeck is currently on lockdown, please, contact local
                  authority for futher information.
                </NoticeBox>
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  icon="lock-open"
                  content="Unlock"
                  textAlign="center"
                  fontSize={1.25}
                  bold
                  onClick={() => act("toggleLock")}
                />
              </Stack.Item>
            </Stack>
          </Modal>
        ) : null}
      </Window.Content>
    </Window>
  );
};

interface HolodeckButtonProps {
  icon: string;
  desc: string;
  selected: boolean;
  disabled?: boolean;
  onClick: () => void;
}

const HolodeckButton = (props: HolodeckButtonProps, _context: any) => {
  const { icon, desc, selected, disabled = false, onClick } = props;

  return (
    <Button
      width={4.5}
      height={4.5}
      fontSize={2}
      style={{
        display: "flex",
        "justify-content": "center",
        "align-items": "center",
      }}
      icon={icon}
      tooltip={desc}
      selected={selected}
      disabled={disabled}
      onClick={() => onClick()}
    />
  );
};
