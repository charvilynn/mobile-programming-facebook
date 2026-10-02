// ─── Sequelize Models Index ───────────────────────────────────────────────────
const { Sequelize } = require('sequelize');
const dbConfig = require('../../config/database');

const env = process.env.NODE_ENV || 'development';
const config = dbConfig[env];

const sequelize = new Sequelize(
  config.database,
  config.username,
  config.password,
  config,
);

// ─── Import Models ────────────────────────────────────────────────────────────
const User              = require('./user.model')(sequelize);
const Post              = require('./post.model')(sequelize);
const Comment           = require('./comment.model')(sequelize);
const Reaction          = require('./reaction.model')(sequelize);
const Connection        = require('./connection.model')(sequelize);
const Message           = require('./message.model')(sequelize);
const Notification      = require('./notification.model')(sequelize);
const Community         = require('./community.model')(sequelize);
const CommunityMember   = require('./community_member.model')(sequelize);
const Event             = require('./event.model')(sequelize);
const EventAttendee     = require('./event_attendee.model')(sequelize);
const MarketItem        = require('./market_item.model')(sequelize);
const RefreshToken      = require('./refresh_token.model')(sequelize);
const Story             = require('./story.model')(sequelize);

// ─── Associations ─────────────────────────────────────────────────────────────

// User ↔ Story
User.hasMany(Story, { foreignKey: 'user_id', as: 'stories' });
Story.belongsTo(User, { foreignKey: 'user_id', as: 'author' });

// User ↔ Post
User.hasMany(Post, { foreignKey: 'user_id', as: 'posts' });
Post.belongsTo(User, { foreignKey: 'user_id', as: 'author' });

// User ↔ Comment
User.hasMany(Comment, { foreignKey: 'user_id', as: 'comments' });
Comment.belongsTo(User, { foreignKey: 'user_id', as: 'author' });

// Post ↔ Comment
Post.hasMany(Comment, { foreignKey: 'post_id', as: 'comments' });
Comment.belongsTo(Post, { foreignKey: 'post_id', as: 'post' });

// Comment self-referencing (replies)
Comment.hasMany(Comment, { foreignKey: 'parent_id', as: 'replies' });
Comment.belongsTo(Comment, { foreignKey: 'parent_id', as: 'parent' });

// Post ↔ Reaction (polymorphic target_type)
Post.hasMany(Reaction, { foreignKey: 'target_id', constraints: false, scope: { target_type: 'post' }, as: 'reactions' });
Comment.hasMany(Reaction, { foreignKey: 'target_id', constraints: false, scope: { target_type: 'comment' }, as: 'reactions' });
User.hasMany(Reaction, { foreignKey: 'user_id', as: 'given_reactions' });

// User ↔ Connection
User.hasMany(Connection, { foreignKey: 'requester_id', as: 'sent_requests' });
User.hasMany(Connection, { foreignKey: 'receiver_id', as: 'received_requests' });
Connection.belongsTo(User, { foreignKey: 'requester_id', as: 'requester' });
Connection.belongsTo(User, { foreignKey: 'receiver_id', as: 'receiver' });

// User ↔ Message
User.hasMany(Message, { foreignKey: 'sender_id', as: 'sent_messages' });
User.hasMany(Message, { foreignKey: 'receiver_id', as: 'received_messages' });
Message.belongsTo(User, { foreignKey: 'sender_id', as: 'sender' });
Message.belongsTo(User, { foreignKey: 'receiver_id', as: 'receiver' });

// User ↔ Notification
User.hasMany(Notification, { foreignKey: 'recipient_id', as: 'notifications' });
User.hasMany(Notification, { foreignKey: 'actor_id', as: 'triggered_notifications' });
Notification.belongsTo(User, { foreignKey: 'actor_id', as: 'actor' });
Notification.belongsTo(User, { foreignKey: 'recipient_id', as: 'recipient' });

// Community
User.hasMany(Community, { foreignKey: 'creator_id', as: 'created_communities' });
Community.belongsTo(User, { foreignKey: 'creator_id', as: 'creator' });
Community.hasMany(CommunityMember, { foreignKey: 'community_id', as: 'members' });
User.hasMany(CommunityMember, { foreignKey: 'user_id', as: 'community_memberships' });

// Event
User.hasMany(Event, { foreignKey: 'organizer_id', as: 'organized_events' });
Event.belongsTo(User, { foreignKey: 'organizer_id', as: 'organizer' });
Event.hasMany(EventAttendee, { foreignKey: 'event_id', as: 'attendees' });
User.hasMany(EventAttendee, { foreignKey: 'user_id', as: 'event_attendances' });

// Marketplace
User.hasMany(MarketItem, { foreignKey: 'seller_id', as: 'listings' });
MarketItem.belongsTo(User, { foreignKey: 'seller_id', as: 'seller' });

// Refresh tokens
User.hasMany(RefreshToken, { foreignKey: 'user_id', as: 'refresh_tokens' });
RefreshToken.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// ─── Export ───────────────────────────────────────────────────────────────────
module.exports = {
  sequelize,
  Sequelize,
  User,
  Post,
  Comment,
  Reaction,
  Connection,
  Message,
  Notification,
  Community,
  CommunityMember,
  Event,
  EventAttendee,
  MarketItem,
  RefreshToken,
  Story,
};