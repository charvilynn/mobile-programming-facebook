const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  return sequelize.define('CommunityMember', {
    id:           { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
    community_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    user_id:      { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    role: {
      type: DataTypes.ENUM('member', 'moderator', 'admin'),
      defaultValue: 'member',
    },
    joined_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  }, {
    tableName: 'community_members',
    indexes: [{ unique: true, fields: ['community_id', 'user_id'] }],
  });
};