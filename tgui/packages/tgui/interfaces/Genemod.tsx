import { BooleanLike } from "common/react";
import { Window } from "../layouts";
import { useBackend } from "../backend";
import {
  AnimatedNumber,
  Box,
  Button,
  Divider,
  ProgressBar,
  Section,
  Stack,
  Table,
} from "../components";
import { toTitleCase } from "common/string";
import { clamp } from "common/math";

type Gene = {
  name: string;
  isStored: BooleanLike;
};

type Data = {
  hasDisk: BooleanLike;
  hasPack: BooleanLike;
  hasGenes: BooleanLike;
  degradation: number;
  modification: number;
  knownGenes: Gene[];
  storedGenes: string[];
};

export const Genemod = (props: any, context: any) => {
  const { act, data, getTheme } = useBackend<Data>(context);
  const {
    hasDisk,
    hasPack,
    hasGenes,
    degradation,
    modification,
    knownGenes,
    storedGenes,
  } = data;

  const handleScramble = () => act("scramble");

  const handleGeneStore = (gene_name: string) =>
    act("store_gene", { value: gene_name });

  const handleGeneApplyAll = () => act("apply_all");
  const handleGeneApply = (gene_name: string) =>
    act("apply_gene", { value: gene_name });

  const handleWipe = () => act("wipe");

  const handleDiskEject = () => act("eject_disk");
  const handlePackEject = () => act("eject_pack");

  return (
    <Window theme={getTheme("primer")} width={425} height={475}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <GeneInfo
              disabled={!hasPack}
              degradation={degradation}
              onGeneScramble={handleScramble}
            />
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Stack fill>
              <Stack.Item grow basis={0}>
                <PackDisplay
                  genes={knownGenes}
                  disabledStore={!hasGenes || !hasDisk}
                  disabledEject={!hasPack}
                  onGeneStore={handleGeneStore}
                  onPackEject={handlePackEject}
                />
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <DiskDisplay
                  genes={storedGenes}
                  modification={modification}
                  disabledApply={!hasPack || !hasDisk}
                  disabledEject={!hasDisk}
                  onApply={handleGeneApply}
                  onWipe={handleWipe}
                  onApplyAll={handleGeneApplyAll}
                  onEject={handleDiskEject}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type GeneInfo = {
  disabled: boolean;
  degradation: number;
  onGeneScramble: () => void;
};

const GeneInfo = (
  { disabled, degradation, onGeneScramble }: GeneInfo,
  _context: any
) => {
  return (
    <Section fill>
      <Stack fill>
        <Stack.Item grow>
          <ProgressBar value={degradation} />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="upload"
            bolds
            textAlign="center"
            tooltip="Scramble Genes"
            disabled={disabled}
            onClick={onGeneScramble}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type PackDisplayProps = {
  genes: Gene[];
  disabledStore: boolean;
  disabledEject: boolean;
  onGeneStore: (gene_name: string) => void;
  onPackEject: () => void;
};

const PackDisplay = (
  {
    genes,
    disabledStore,
    disabledEject,
    onGeneStore,
    onPackEject,
  }: PackDisplayProps,
  _context: any
) => {
  return (
    <Stack fill vertical>
      <Stack.Item grow basis={0}>
        <Section fill title="Genome Data">
          <Table>
            {genes.map((gene: Gene, index: number) => (
              <Table.Row key={index} className="candystripe">
                <Table.Cell pl={1} py={0.4}>
                  {toTitleCase(gene.name)}
                </Table.Cell>
                <Table.Cell collapsing pr={1} textAlign="right">
                  <Button
                    icon={gene.isStored ? "rotate" : "floppy-disk"}
                    color="transparent"
                    tooltip={gene.isStored ? "Owerwrite" : "Store"}
                    disabled={disabledStore}
                    onClick={() => onGeneStore(gene.name)}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          bold
          disabled={disabledEject}
          icon="eject"
          color="bad"
          textAlign="center"
          fontSize={1.2}
          py={0.5}
          onClick={onPackEject}
        >
          Eject Pack
        </Button>
      </Stack.Item>
    </Stack>
  );
};

type DiskDisplayProps = {
  genes: string[];
  modification: number;
  disabledApply: boolean;
  disabledEject: boolean;
  onApply: (gene_name: string) => void;
  onApplyAll: () => void;
  onEject: () => void;
  onWipe: () => void;
};

const DiskDisplay = (
  {
    genes,
    modification,
    disabledApply,
    disabledEject,
    onApply,
    onApplyAll,
    onEject,
    onWipe,
  }: DiskDisplayProps,
  _context: any
) => {
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill title="Stored Genes">
          <Stack fill vertical>
            <Stack.Item grow>
              <Box bold>
                Failure Probability:{" "}
                <AnimatedNumber
                  value={modification}
                  format={(value: number) =>
                    `${clamp(value, 0, 100).toLocaleString()}%`
                  }
                />
              </Box>
              <Divider />
              <Table>
                {(genes.length &&
                  genes.map((geneName: string, index: number) => (
                    <Table.Row key={index} className="candystripe">
                      <Table.Cell pl={1} py={0.4}>
                        {toTitleCase(geneName)}
                      </Table.Cell>
                      <Table.Cell collapsing pr={1} textAlign="right">
                        <Button
                          icon="plus"
                          tooltip="Apply"
                          disabled={disabledApply}
                          onClick={() => onApply(geneName)}
                        />
                      </Table.Cell>
                    </Table.Row>
                  ))) || (
                  <Table.Row>
                    <Table.Cell />
                    <Table.Cell pl={0.5}>Empty</Table.Cell>
                    <Table.Cell />
                  </Table.Row>
                )}
              </Table>
            </Stack.Item>
            <Stack.Item>
              <Stack>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="trash"
                    color="bad"
                    textAlign="center"
                    disabled={disabledEject}
                    onClick={onWipe}
                  >
                    Wipe
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    icon="upload"
                    textAlign="center"
                    disabled={disabledApply}
                    onClick={onApplyAll}
                  >
                    Apply All
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          bold
          icon="eject"
          color="bad"
          textAlign="center"
          fontSize={1.2}
          py={0.5}
          disabled={disabledEject}
          onClick={onEject}
        >
          Eject Disk
        </Button>
      </Stack.Item>
    </Stack>
  );
};
