import { Icon } from '../../../components';
import type { PdaProgram } from '../types';

export const NewsFeedProgram: PdaProgram = {
  id: 'news_feed',
  title: 'News Feed',
  icon: 'radio',
  View: () => (
    <div className="PDAProgram PDAProgram--generic">
      <div className="PDAProgram__header">
        <div className="PDAProgram__title"><Icon name="radio" /> NEWS FEED</div>
        <div className="PDAProgram__sub">Mock bulletin • backend-ready</div>
      </div>

      <div className="PDAProgram__panel">
        <div className="PDAProgram__listItem">NT Bulletin: Routine inspection scheduled.</div>
        <div className="PDAProgram__listItem">Security Advisory: Report suspicious activity.</div>
      </div>
    </div>
  ),
};
