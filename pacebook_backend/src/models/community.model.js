const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  return sequelize.define('Community', {
    id:          { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
    creator_id:  { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    name:        { type: DataTypes.STRING(100), allowNull: false },
    description: { type: DataTypes.TEXT, allowNull: true },
    avatar_url:  { type: DataTypes.STRING(500), allowNull: true },
    cover_url:   { type: DataTypes.STRING(500), allowNull: true },
    category:    { type: DataTypes.STRING(50), allowNull: true },
    privacy: {
      type: DataTypes.ENUM('public', 'private'),
      defaultValue: 'public',
    },
    member_count: { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 },
    post_count:   { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 },
    is_active:    { type: DataTypes.BOOLEAN, defaultValue: true },
  }, { tableName: 'communities' });
};