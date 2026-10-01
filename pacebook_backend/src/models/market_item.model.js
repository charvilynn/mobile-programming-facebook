const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  return sequelize.define('MarketItem', {
    id:          { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
    seller_id:   { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    title:       { type: DataTypes.STRING(200), allowNull: false },
    description: { type: DataTypes.TEXT, allowNull: true },
    price:       { type: DataTypes.DECIMAL(14, 2), allowNull: false, validate: { min: 0 } },
    condition: {
      type: DataTypes.ENUM('new', 'like_new', 'good', 'fair', 'for_parts'),
      defaultValue: 'good',
    },
    category:   { type: DataTypes.STRING(50), allowNull: true },
    location:   { type: DataTypes.STRING(200), allowNull: true },
    image_urls: { type: DataTypes.JSON, defaultValue: [] },
    status: {
      type: DataTypes.ENUM('available', 'reserved', 'sold'),
      defaultValue: 'available',
    },
    view_count:    { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 },
    interest_count: { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 },
    is_negotiable: { type: DataTypes.BOOLEAN, defaultValue: true },
    is_deleted:    { type: DataTypes.BOOLEAN, defaultValue: false },
  }, { tableName: 'market_items' });
};