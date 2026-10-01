const { DataTypes } = require('sequelize');
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize) => {
  return sequelize.define('RefreshToken', {
    id:         { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
    user_id:    { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    token:      { type: DataTypes.STRING(500), allowNull: false, unique: true },
    expires_at: { type: DataTypes.DATE, allowNull: false },
    is_revoked: { type: DataTypes.BOOLEAN, defaultValue: false },
    device_info: { type: DataTypes.STRING(200), allowNull: true },
  }, {
    tableName: 'refresh_tokens',
    hooks: {
      beforeCreate: (token) => {
        if (!token.token) token.token = uuidv4();
      },
    },
  });
};