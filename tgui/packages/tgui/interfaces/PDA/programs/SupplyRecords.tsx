import { Icon } from '../../../components';
import { PDA_MODE } from '../programIds';
import type { PdaProgram, PdaProgramContext } from '../types';

const SupplyRecordsApp = (props: { ctx: PdaProgramContext }) => {
  const { ctx } = props;
  const supply = ctx.data?.records?.supply || {};
  const approved = supply.approved || [];
  const requests = supply.requests || [];

  return (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title">
          <Icon name="box" /> SUPPLY RECORD INTERLINK
        </div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__row">
          <div className="PDAProgram__k">Shuttle</div>
          <div className="PDAProgram__v">
            {supply.shuttle_moving
              ? `Moving to dock (${supply.shuttle_eta})`
              : `Shuttle at ${supply.shuttle_loc}`}
          </div>
        </div>

        <div className="PDAProgram__splitPanel">
          <div>
            <div className="PDAProgram__sectionTitle">Approved Orders</div>
            {(approved.length && supply.approved_count) ? approved.map((order, idx) => (
              <div key={idx} className="PDAProgram__orderCard is-approved">
                <div className="PDAProgram__orderHead">
                  <span>#{order.Number}</span>
                  <span className="PDAProgram__orderBy">Approved</span>
                </div>
                <div className="PDAProgram__orderName">{order.Name}</div>
                <div className="PDAProgram__orderMeta">By: {order.OrderedBy || order.ApprovedBy || 'Unknown'}</div>
                {!!order.Comment && <div className="PDAProgram__orderComment">{order.Comment}</div>}
              </div>
            )) : <div className="PDAProgram__footerHint">No current approved orders.</div>}
          </div>

          <div>
            <div className="PDAProgram__sectionTitle">Requested Orders</div>
            {(requests.length && supply.requests_count) ? requests.map((order, idx) => (
              <div key={idx} className="PDAProgram__orderCard is-requested">
                <div className="PDAProgram__orderHead">
                  <span>#{order.Number}</span>
                  <span className="PDAProgram__orderBy">Requested</span>
                </div>
                <div className="PDAProgram__orderName">{order.Name}</div>
                <div className="PDAProgram__orderMeta">By: {order.OrderedBy || order.ApprovedBy || 'Unknown'}</div>
                {!!order.Comment && <div className="PDAProgram__orderComment">{order.Comment}</div>}
              </div>
            )) : <div className="PDAProgram__footerHint">No current requested orders.</div>}
          </div>
        </div>
      </div>
    </div>
  );
};

export const SupplyRecordsProgram: PdaProgram = {
  id: PDA_MODE.SUPPLY_RECORDS,
  title: 'Supply Records',
  icon: 'box',
  View: (ctx) => <SupplyRecordsApp ctx={ctx} />,
};
