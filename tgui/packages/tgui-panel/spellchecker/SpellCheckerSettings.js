import { useDispatch, useSelector } from "../../common/redux";
import {
  Box,
  Divider,
  LabeledList,
  Section,
  TextArea,
  Button,
} from "../../tgui/components";
import { updateSpellCheckerSettings } from "./actions";
import { defaultBlacklist } from "./reducer";
import { selectSpellChecker } from "./selector";

export const SpellCheckerSettings = (props, context) => {
  const { enabled, blacklist } = useSelector(context, selectSpellChecker);
  const dispatch = useDispatch(context);

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Enable">
          <Button.Checkbox
            checked={enabled}
            tooltip="Enables spell checking of an input text."
            tooltipPosition="right"
            onClick={() =>
              dispatch(
                updateSpellCheckerSettings({
                  enabled: !enabled,
                })
              )
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Restore Blacklist">
          <Button.Confirm
            icon="trash"
            tooltip="Restores the blacklist to default words."
            tooltipPosition="right"
            onClick={() =>
              dispatch(
                updateSpellCheckerSettings({
                  blacklist: defaultBlacklist,
                })
              )
            }
          />
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Box direction="column" mb={1} color="label" align="baseline">
        Blacklist (comma separated):
        <TextArea
          height="6em"
          value={blacklist}
          onChange={(e, value) =>
            dispatch(
              updateSpellCheckerSettings({
                blacklist: value,
              })
            )
          }
        />
      </Box>
    </Section>
  );
};
