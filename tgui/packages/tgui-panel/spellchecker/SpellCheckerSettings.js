import { useDispatch, useSelector } from '../../common/redux';
import {
  Box,
  Divider,
  Flex,
  LabeledList,
  Section,
  TextArea,
} from '../../tgui/components';
import { Button } from '../../tgui/components';
import { logger } from '../../tgui/logging';
import { updateSettings } from '../settings/actions';
import { updateSpellCheckerSettings } from './actions';
import { selectSpellChecker } from './selector';

export const SpellCheckerSettings = (props, context) => {
  const { enabled, blacklist } = useSelector(context, selectSpellChecker);
  const dispatch = useDispatch(context);

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Enable">
          <Button.Checkbox
            checked={enabled}
            onClick={() =>
              dispatch(
                updateSpellCheckerSettings({
                  enabled: !enabled,
                }))}
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
              }))}
        />
      </Box>
    </Section>
  );
};
