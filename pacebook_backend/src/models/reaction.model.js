const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  return sequelize.define('Reaction', {
    id:          { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
    user_id:     { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    target_id:   { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    target_type: { type: DataTypes.ENUM('post', 'comment'), allowNull: false },
    type: {
      type: DataTypes.ENUM('like', 'love', 'haha', 'wow', 'sad', 'angry'),
      defaultValue: 'like',
    },
  }, {
    tableName: 'reactions',
    indexes: [{ unique: true, fields: ['user_id', 'target_id', 'target_type'] }],
  });
};