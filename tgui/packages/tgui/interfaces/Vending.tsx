import { useBackend, useLocalState } from '../backend';
import { Box, Button, Divider, LabeledList, Stack } from '../components';
import { Window } from '../layouts';

export interface InputData {
  mode: number;
  products: Product[];
  panel: number;
  ad: string;
  product: string;
  price: number;
  message: string;
  coin: string;
}

export interface Product {
  key: number;
  name: string;
  price: number;
  color: null;
  amount: number;
}

const product = (product: Product, context: any) => {
  const { act, data } = useBackend<InputData>(context);
  const outOfStock = product.amount === 0;
  const isUseCoins = product.price === 0;

  return (
    <Button
      className='Button--product'
      fluid
      disabled={outOfStock}
      onClick={() => act('vend', { vend: product.key })}>
      <Stack>
        <Stack.Item>
          <Box className='AmountCounter'>
            {product.amount.toString().padStart(2, '0')}
          </Box>
        </Stack.Item>
        <Stack.Item>{product.name} - </Stack.Item>
        <Stack.Item>
          {(outOfStock && 'Out of Stock!') || (
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
          )}
        </Stack.Item>
      </Stack>
    </Button>
  );
};

const pay = (props: any, context: any) => {
  const { act, data } = useBackend<InputData>(context);

  return (
    <Box className='Payment'>
      <h1>Payment</h1>

      <LabeledList>
        <LabeledList.Item label='Product'>{data.product}</LabeledList.Item>
        <LabeledList.Item label='Price'>
          {data.price}{' '}
          <i style={{ 'margin-left': '.5rem' }} class='fas fa-money-bill-alt' />
        </LabeledList.Item>
      </LabeledList>
      <Divider hidden />
      {data.message}
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
    </Box>
  );
};

export const Vending = (props: any, context: any) => {
  const { act, data, getTheme } = useBackend<InputData>(context);
  const { products, mode } = data;

  return (
    <Window
      width={400}
      height={600}
      theme={getTheme('vending')}
      title='Vending Machine'>
      <Window.Content scrollable>
        {mode === 0 && data.coin && (
          <Button
            icon='coins'
            className='Button--pay'
            fluid
            content={`Eject ${data.coin}`}
            onClick={() => act('remove_coin')}
          />
        )}
        {mode === 0
          ? products.map((value, i) => product(value, context))
          : pay(props, context)}
      </Window.Content>
    </Window>
  );
};
