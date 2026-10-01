const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  return sequelize.define('Notification', {
    id:           { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
    recipient_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    actor_id:     { type: DataTypes.INTEGER.UNSIGNED, allowNull: true }, // null for system notifications
    type: {
      type: DataTypes.ENUM(
        'connection_request', 'friend_request', 'connection_accepted',
        'post_reaction', 'post_comment', 'comment_reply',
        'new_message', 'community_invite', 'event_invite',
        'market_interest', 'system', 'post_tag'
      ),
      allowNull: false,
    },
    reference_id:   { type: DataTypes.INTEGER.UNSIGNED, allowNull: true },
    reference_type: { type: DataTypes.STRING(50), allowNull: true },
    body:    { type: DataTypes.STRING(500), allowNull: false },
    is_read: { type: DataTypes.BOOLEAN, defaultValue: false },
    read_at: { type: DataTypes.DATE, allowNull: true },
  }, { tableName: 'notifications' });
};