const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  return sequelize.define('Story', {
    id: {
      type: DataTypes.INTEGER.UNSIGNED,
      primaryKey: true,
      autoIncrement: true,
    },
    user_id: {
      type: DataTypes.INTEGER.UNSIGNED,
      allowNull: false,
    },
    media_url: {
      type: DataTypes.TEXT('long'),
      allowNull: true,
    },
    text_content: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    bg_color: {
      type: DataTypes.STRING(50),
      defaultValue: '#0A192F',
    },
    type: {
      type: DataTypes.ENUM('image', 'text'),
      defaultValue: 'image',
    },
    expires_at: {
      type: DataTypes.DATE,
      allowNull: false,
    },
  }, {
    tableName: 'stories',
    timestamps: true,
  });
};