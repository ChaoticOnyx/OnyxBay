import { useBackend } from '../backend';
import {
  Button,
  Divider,
  Icon,
  LabeledList,
  Modal,
  Stack,
} from '../components';
import { Window } from '../layouts';

export interface InputData {
  mode: number;
  products: Product[];
  panel: number;
  coin: string;
  payment?: Payment;
  name: string;
  speaker: number;
}

export interface Product {
  key: number;
  name: string;
  price: number;
  color: null;
  amount: number;
  icon: string;
}

export interface Payment {
  message: string;
  price: number;
  product: string;
  icon: string;
  message_err: number;
}

const product = (product: Product, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const outOfStock = product.amount === 0;
  const isUseCoins = product.price === 0;
  const iconSrc = product.icon.match('src="(.*)"')[1];

  return (
    <Button
      className='Button--product'
      fluid
      disabled={outOfStock}
      onClick={() => act('vend', { vend: product.key })}>
      <Stack>
        <Stack.Item>
          {product.amount}{' '}
          <i style={{ 'margin-left': '.1rem' }} class='fas fa-shopping-cart' />
        </Stack.Item>
        <Stack.Item ml='0'>
          {
            <>
              {isUseCoins ? 1 : product.price}
              {isUseCoins ? (
                <i style={{ 'margin-left': '.1rem' }} class='fas fa-coins' />
              ) : (
                <i
                  style={{ 'margin-left': '.5rem' }}
                  class='fas fa-money-bill-alt'
                />
              )}
            </>
          }
        </Stack.Item>
        <Stack.Item>
          <img
            class='ProductIcon'
            src={iconSrc}
            style={{ '-ms-interpolation-mode': 'nearest-neighbor' }}
          />
        </Stack.Item>
        <Stack.Item>{product.name}</Stack.Item>
      </Stack>
    </Button>
  );
};

const pay = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const { payment } = data;
  const iconSrc = payment.icon.match('src="(.*)"')[1];

  return (
    <Modal className='Payment'>
      <h1>Payment</h1>

      <LabeledList>
        <LabeledList.Item label='Product'>
          <img
            class='ProductIcon'
            src={iconSrc}
            style={{ '-ms-interpolation-mode': 'nearest-neighbor' }}
          />
          {payment.product}
        </LabeledList.Item>
        <LabeledList.Item label='Price'>
          {payment.price}{' '}
          <i style={{ 'margin-left': '.5rem' }} class='fas fa-money-bill-alt' />
        </LabeledList.Item>
      </LabeledList>
      <Divider hidden />
      {(payment.message_err && <Icon mr='.5rem' name='exclamation-circle' />)
        || null}
      {payment.message}
      <Divider hidden />
      <Stack justify='space-between' align='center'>
        <Stack.Item width='100%'>
          <Button
            className='Button--pay'
            fluid
            icon='money-check'
            content='Pay'
            onClick={() => act('pay')}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            className='Button--cancel'
            icon='ban'
            content='Cancel'
            onClick={() => act('cancelpurchase')}
          />
        </Stack.Item>
      </Stack>
    </Modal>
  );
};

export const Vending = (props: any, context: any) => {
  const { act, data, getTheme } = useBackend<InputData>(context);
  const { products, mode } = data;

  return (
    <Window
      width={500}
      height={600}
      theme={getTheme('vending')}
      title={`Vending Machine - ${data.name}`}>
      <Window.Content scrollable>
        {(data.panel && (
          <Button
            className='Button--pay'
            icon='volume-up'
            fluid
            content={`Speaker ${data.speaker ? 'Enabled' : 'Disabled'}`}
            onClick={() => act('togglevoice')}
          />
        ))
          || null}
        {data.coin && (
          <Button
            icon='coins'
            className='Button--pay'
            fluid
            content={`Eject ${data.coin}`}
            onClick={() => act('remove_coin')}
          />
        )}
        {products.map((value, i) => product(value, context))}
      </Window.Content>
      {mode === 1 && pay(props, context)}
    </Window>
  );
};
