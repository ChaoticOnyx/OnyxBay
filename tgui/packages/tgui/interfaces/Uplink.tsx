import { createSearch, decodeHtmlEntities } from "common/string";
import { useBackend, useLocalState } from "../backend";
import {
  Button,
  Stack,
  Input,
  Section,
  Tabs,
  NoticeBox,
  LabeledList,
  Table,
  Divider,
} from "../components";
import { formatMoney } from "../format";
import { Window } from "../layouts";

const MAX_SEARCH_RESULTS = 25;

interface Item {
  name: string;
  cost: number;
  desc: string;
  path: string;
  manufacturer: string;
}

interface Category {
  name: string;
  items: Item[];
}

interface Contract {
  name: string;
  category: string;
  desc: string;
  reward: number;
}

interface ContractCategory {
  name: string;
  contracts: Contract[];
}

interface ExploitData {
  Name: string;
  Sex: string;
  Age: string;
  Species: string;
  "Home System": string;
  Background: string;
  Religion: string;
  Fingerprint: string;
  "Exploitable Information": string;
}

interface Exploit {
  name: string;
  uid: string;
}

interface InputData {
  itemCategories: Category[];
  contractCategories: ContractCategory[];
  crewRecords: Exploit[];
  exploitData: ExploitData;
  telecrystals: number;
  lockable: boolean;
}

enum MenuPage {
  UplinkMenu,
  ContractMenu,
  ExploitableMenu,
}

export const Uplink = (props: InputData, context: any) => {
  const { data } = useBackend<InputData>(context);
  const { telecrystals } = data;
  return (
    <Window width={620} height={580} theme="syndicate">
      <Window.Content scrollable>
        <GenericUplink currencyAmount={telecrystals} currencySymbol="TC" />
      </Window.Content>
    </Window>
  );
};

export const GenericUplink = (props: any, context: any) => {
  const { currencyAmount = 0, currencySymbol = "cr" } = props;
  const { act, data } = useBackend<InputData>(context);
  const [searchText, setSearchText] = useLocalState(context, "searchText", "");
  const [currentPage, setCurrentPage] = useLocalState(
    context,
    "currentPage",
    0
  );
  const [compactMode, setCompactMode] = useLocalState(
    context,
    "compactMode",
    false
  );
  const [selectedItemCategory, setSelectedItemCategory] = useLocalState(
    context,
    "itemCategory",
    data.itemCategories[0]?.name
  );
  const [selectedContractCategory, setSelectedContractCategory] = useLocalState(
    context,
    "contractCategory",
    data.contractCategories[0]?.name
  );
  const testSearch = createSearch<Item>(searchText, (item) => {
    return item.name + item.desc;
  });
  const items =
    (searchText.length > 0 &&
      data.itemCategories
        .flatMap((category) => category.items || [])
        .filter(testSearch)
        .filter((item, i) => i < MAX_SEARCH_RESULTS)) ||
    data.itemCategories.find(
      (category) => category.name === selectedItemCategory
    )?.items ||
    [];
  const contracts =
    data.contractCategories.find(
      (category) => category.name === selectedContractCategory
    )?.contracts || [];

  return (
    <Section
      title={`${formatMoney(currencyAmount)} ${currencySymbol}`}
      buttons={
        <>
          {currentPage === MenuPage.UplinkMenu ? (
            <>
              <Input
                autoFocus
                placeholder="Search"
                value={searchText}
                onInput={(_, value) => setSearchText(value)}
                mx={1}
              />
              <Button
                icon={compactMode ? "list" : "info"}
                content={compactMode ? "Compact" : "Detailed"}
                onClick={() => setCompactMode(!compactMode)}
              />
            </>
          ) : (
            <></>
          )}
          <Button
            color="transparent"
            icon="shopping-basket"
            selected={currentPage === MenuPage.UplinkMenu}
            onClick={() => setCurrentPage(MenuPage.UplinkMenu)}
            textAlign="center"
            bold={true}
          >
            Items
          </Button>
          <Button
            color="transparent"
            icon="file-contract"
            selected={currentPage === MenuPage.ContractMenu}
            onClick={() => setCurrentPage(MenuPage.ContractMenu)}
            textAlign="center"
            bold={true}
          >
            Contracts
          </Button>
          <Button
            color="transparent"
            icon="id-card-clip"
            selected={currentPage === MenuPage.ExploitableMenu}
            onClick={() => setCurrentPage(MenuPage.ExploitableMenu)}
            textAlign="center"
            bold={true}
          >
            Exploitable Info
          </Button>
          {data.lockable ? (
            <Button icon="lock" content="Lock" onClick={() => act("lock")} />
          ) : (
            <></>
          )}
        </>
      }
    >
      <Stack fill>
        <Stack.Item grow basis={0}>
          {currentPage === MenuPage.UplinkMenu && (
            <UplinkMenu
              categories={data.itemCategories}
              searchText={searchText}
              selectedItemCategory={selectedItemCategory}
              currencyAmount={currencyAmount}
              currencySymbol={currencySymbol}
              compactMode={compactMode}
              items={items}
              onItemCategorySelect={(category: string) =>
                setSelectedItemCategory(category)
              }
            />
          )}
          {currentPage === MenuPage.ContractMenu && (
            <ContractsMenu
              contractCategories={data.contractCategories}
              selectedContractCategory={selectedContractCategory}
              currencySymbol={currencySymbol}
              contracts={contracts}
              onContractCatgorySelect={(category: string) =>
                setSelectedContractCategory(category)
              }
            />
          )}
          {currentPage === MenuPage.ExploitableMenu && (
            <ExploitableMenu
              exploits={data.crewRecords}
              selectedExploit={data.exploitData}
            />
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

interface UplinkMenuProps {
  categories: Category[];
  searchText: string;
  selectedItemCategory: string;
  currencyAmount: number;
  currencySymbol: string;
  compactMode: boolean;
  items: Item[];
  onItemCategorySelect: (category: string) => void;
}

const UplinkMenu = (props: UplinkMenuProps, context: any) => {
  const {
    categories,
    searchText,
    selectedItemCategory,
    currencyAmount,
    currencySymbol,
    compactMode,
    items,
    onItemCategorySelect,
  } = props;

  return (
    <Stack fill>
      {searchText.length === 0 && (
        <Stack.Item mr={1.5}>
          <Tabs vertical>
            {categories?.map((category) => (
              <>
                {category.items.length ? (
                  <Tabs.Tab
                    key={category.name}
                    selected={category.name === selectedItemCategory}
                    onClick={() => onItemCategorySelect(category.name)}
                  >
                    {category.name} ({category.items?.length || 0})
                  </Tabs.Tab>
                ) : (
                  <></>
                )}
              </>
            ))}
          </Tabs>
        </Stack.Item>
      )}
      {items?.length === 0 && (
        <NoticeBox>
          {searchText.length === 0
            ? "No items in this category."
            : "No results found."}
        </NoticeBox>
      )}
      <Stack.Item grow basis={0}>
        <ItemList
          compactMode={searchText.length > 0 || compactMode}
          currencyAmount={currencyAmount}
          currencySymbol={currencySymbol}
          currentItems={items}
        />
      </Stack.Item>
    </Stack>
  );
};

interface ItemListProps {
  compactMode: boolean;
  currencyAmount: number;
  currencySymbol: string;
  currentItems: Item[];
}

const ItemList = (props: ItemListProps, context: any) => {
  const { compactMode, currencyAmount, currencySymbol, currentItems } = props;
  const { act } = useBackend(context);
  const [hoveredItem, setHoveredItem] = useLocalState<Item>(
    context,
    "hoveredItem",
    null
  );
  const hoveredCost = (hoveredItem && hoveredItem.cost) || 0;
  const items = currentItems?.map((item) => {
    const notSameItem = hoveredItem && hoveredItem.name !== item.name;
    const notEnoughHovered = currencyAmount - hoveredCost < item.cost;
    const disabledDueToHovered = notSameItem && notEnoughHovered;
    const disabled = currencyAmount < item.cost || disabledDueToHovered;
    return {
      ...item,
      disabled,
    };
  });
  if (compactMode) {
    return (
      <Table>
        {items?.map((item) => (
          <Table.Row key={item.name} className="candystripe">
            <Table.Cell bold>{decodeHtmlEntities(item.name)}</Table.Cell>
            <Table.Cell collapsing textAlign="right">
              <Button
                fluid
                content={formatMoney(item.cost) + " " + currencySymbol}
                disabled={item.disabled}
                tooltip={item.desc}
                tooltipPosition="left"
                onmouseover={() => setHoveredItem(item)}
                onmouseout={() => setHoveredItem(null)}
                onClick={() =>
                  act("buy", {
                    name: item.name,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    );
  }

  if (!compactMode) {
    return (
      <>
        {items?.map((item) => (
          <Section
            key={item.name}
            title={item.name}
            buttons={
              <Button
                content={item.cost + " " + currencySymbol}
                disabled={item.disabled}
                onmouseover={() => setHoveredItem(item)}
                onmouseout={() => setHoveredItem(null)}
                onClick={() =>
                  act("buy", {
                    name: item.name,
                  })
                }
              />
            }
          >
            {decodeHtmlEntities(item.desc)}
          </Section>
        ))}
      </>
    );
  }
};

interface ContractMenuProps {
  contractCategories: ContractCategory[];
  selectedContractCategory: string;
  currencySymbol: string;
  contracts: Contract[];
  onContractCatgorySelect: (category: string) => void;
}

const ContractsMenu = (props: ContractMenuProps, context: any) => {
  const {
    contractCategories,
    selectedContractCategory,
    currencySymbol,
    contracts,
    onContractCatgorySelect,
  } = props;
  return (
    <Stack fill>
      <Stack.Item mr={1.5}>
        <Tabs vertical>
          {contractCategories?.map((category) => (
            <>
              {category.contracts?.length ? (
                <Tabs.Tab
                  key={category.name}
                  selected={category.name === selectedContractCategory}
                  onClick={() => onContractCatgorySelect(category.name)}
                >
                  {category.name} ({category.contracts?.length || 0})
                </Tabs.Tab>
              ) : (
                <> </>
              )}
            </>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        {contracts?.map((contract) => (
          <Section
            key={contract.name}
            title={contract.name}
            buttons={
              <Button
                content={"Reward: " + contract.reward + " " + currencySymbol}
              />
            }
          >
            {decodeHtmlEntities(contract.desc)}{" "}
          </Section>
        ))}
      </Stack.Item>
    </Stack>
  );
};

interface ExploitableMenuProps {
  exploits: Exploit[];
  selectedExploit: ExploitData;
}

const ExploitableMenu = (props: ExploitableMenuProps, context: any) => {
  const { act } = useBackend<InputData>(context);
  const { exploits, selectedExploit } = props;
  return (
    <Stack vertical fill>
      <Stack.Item>
        {exploits?.map((exploit) => (
          <Stack.Item>
            <Button
              onClick={() =>
                act("select_exploit", {
                  uid: exploit.uid,
                })
              }
            >
              {exploit.name}
            </Button>
          </Stack.Item>
        ))}
      </Stack.Item>
      {selectedExploit?.Name ? (
        <Stack.Item>
          <h1>Information</h1>
          <LabeledList>
            <LabeledList.Item label="Name">
              {selectedExploit.Name}
            </LabeledList.Item>

            <LabeledList.Item label="Sex">
              {selectedExploit.Sex}
            </LabeledList.Item>

            <LabeledList.Item label="Age">
              {selectedExploit.Age}
            </LabeledList.Item>

            <LabeledList.Item label="Species">
              {selectedExploit.Species}
            </LabeledList.Item>

            <LabeledList.Item label="Home System">
              {selectedExploit["Home System"]}
            </LabeledList.Item>

            <LabeledList.Item label="Background">
              {selectedExploit.Background}
            </LabeledList.Item>

            <LabeledList.Item label="Religion">
              {selectedExploit.Religion}
            </LabeledList.Item>

            <LabeledList.Item label="Fingerprint">
              {selectedExploit.Fingerprint}
            </LabeledList.Item>

            <LabeledList.Item label="Exploitable information">
              {selectedExploit["Exploitable Information"] || "N/A"}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      ) : (
        <></>
      )}
    </Stack>
  );
};
