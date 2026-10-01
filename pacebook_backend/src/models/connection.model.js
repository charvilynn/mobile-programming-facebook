const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  return sequelize.define('Connection', {
    id:           { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
    requester_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    receiver_id:  { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    status: {
      type: DataTypes.ENUM('pending', 'accepted', 'rejected', 'blocked'),
      defaultValue: 'pending',
    },
    accepted_at:  { type: DataTypes.DATE, allowNull: true },
  }, {
    tableName: 'connections',
    indexes: [{ unique: true, fields: ['requester_id', 'receiver_id'] }],
  });
};