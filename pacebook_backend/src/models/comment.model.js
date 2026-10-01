const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  return sequelize.define('Comment', {
    id:        { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
    post_id:   { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    user_id:   { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    parent_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: true }, // null = top-level
    content:   { type: DataTypes.TEXT, allowNull: false, validate: { len: [1, 2000] } },
    reaction_count: { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 },
    reply_count:    { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 },
    is_deleted: { type: DataTypes.BOOLEAN, defaultValue: false },
  }, { tableName: 'comments' });
};