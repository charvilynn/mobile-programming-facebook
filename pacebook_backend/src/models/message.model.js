const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  return sequelize.define('Message', {
    id:          { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
    sender_id:   { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    receiver_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    content:     { type: DataTypes.TEXT, allowNull: false, validate: { len: [1, 5000] } },
    media_url:   { type: DataTypes.STRING(500), allowNull: true },
    is_read:     { type: DataTypes.BOOLEAN, defaultValue: false },
    read_at:     { type: DataTypes.DATE, allowNull: true },
    is_deleted:  { type: DataTypes.BOOLEAN, defaultValue: false },
  }, { tableName: 'messages' });
};