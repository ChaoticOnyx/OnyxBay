import { useBackend } from "../backend";
import {
  Button,
  Divider,
  Icon,
  LabeledList,
  Modal,
  Stack,
} from "../components";
import { GameIcon } from "../components/GameIcon";
import { Window } from "../layouts";

interface Product {
  key: number;
  name: string;
  price: number;
  color: null;
  amount: number;
  icon: string;
}

interface Payment {
  message: string;
  price: number;
  product: string;
  icon: string;
  // eslint-disable-next-line camelcase
  message_err: number;
}

interface InputData {
  mode: number;
  products: Product[];
  panel: number;
  coin?: string;
  payment?: Payment;
  name: string;
  speaker: number;
  ready: number;
}

const product = (product: Product, context: any) => {
  const { act } = useBackend<InputData>(context);
  const outOfStock = product.amount === 0;
  const isFree = product.price === 0;
  const capitalizedName =
    product.name[0].toUpperCase() + product.name.substr(1);

  return (
    <Button
      className="Button--product"
      fluid
      disabled={outOfStock}
      tooltip={(!isFree && `In Stock: ${product.amount}`) || null}
      onClick={() => act("vend", { vend: product.key })}
    >
      <Stack align="center">
        <Stack.Item>
          <GameIcon className="ProductIcon" html={product.icon} />
        </Stack.Item>
        <Stack.Item width="100%">{capitalizedName}</Stack.Item>
        <Stack.Item mr={0}>
          {
            <>
              {isFree ? product.amount : product.price}
              {isFree ? (
                <i
                  style={{ "margin-left": ".5rem" }}
                  className="fas fa-boxes"
                />
              ) : (
                <i
                  style={{ "margin-left": ".5rem" }}
                  className="fas fa-money-bill-alt"
                />
              )}
            </>
          }
        </Stack.Item>
      </Stack>
    </Button>
  );
};

const pay = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { payment } = data;

  return (
    <Modal className="Payment">
      <h1>Payment</h1>

      <LabeledList>
        <LabeledList.Item label="Product">
          <GameIcon className="ProductIcon" html={payment.icon} />
          {payment.product}
        </LabeledList.Item>
        <LabeledList.Item label="Price">
          {payment.price}{" "}
          <i
            style={{ "margin-left": ".5rem" }}
            className="fas fa-money-bill-alt"
          />
        </LabeledList.Item>
      </LabeledList>
      <Divider hidden />
      {(payment.message_err && <Icon mr=".5rem" name="exclamation-circle" />) ||
        null}
      {payment.message}
      <Divider hidden />
      <Stack justify="space-between" align="center">
        <Stack.Item width="100%">
          <Button
            className="Button--pay"
            fluid
            icon="money-check"
            content="Pay"
            onClick={() => act("pay")}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            className="Button--cancel"
            icon="ban"
            content="Cancel"
            onClick={() => act("cancelpurchase")}
          />
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

const vendingProgress = () => {
  return (
    <Modal className="VendingProgress">
      <Stack>
        <Stack.Item>Vending...</Stack.Item>
        <Stack.Item>
          <Icon spin name="spinner" />
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

export const Vending = (props: any, context: any) => {
  const { act, data, getTheme } = useBackend<InputData>(context);
  const { products, mode, ready } = data;

  return (
    <Window
      width={500}
      height={600}
      theme={getTheme("vending")}
      title={`Vending Machine - ${data.name}`}
    >
      <Window.Content scrollable>
        {(data.panel && (
          <Button
            className="Button--pay"
            icon="volume-up"
            fluid
            content={`Speaker ${data.speaker ? "Enabled" : "Disabled"}`}
            onClick={() => act("togglevoice")}
          />
        )) ||
          null}
        {data.coin && (
          <Button
            icon="coins"
            className="Button--pay"
            fluid
            content={`Eject ${data.coin}`}
            onClick={() => act("remove_coin")}
          />
        )}
        {products.map((value, i) => product(value, context))}
      </Window.Content>
      {mode === 1 && pay(props, context)}
      {!ready && vendingProgress()}
    </Window>
  );
};
