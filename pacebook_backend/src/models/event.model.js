const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  return sequelize.define('Event', {
    id:           { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
    organizer_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    title:        { type: DataTypes.STRING(200), allowNull: false },
    description:  { type: DataTypes.TEXT, allowNull: true },
    cover_url:    { type: DataTypes.STRING(500), allowNull: true },
    location:     { type: DataTypes.STRING(300), allowNull: true },
    is_online:    { type: DataTypes.BOOLEAN, defaultValue: false },
    online_link:  { type: DataTypes.STRING(500), allowNull: true },
    starts_at:    { type: DataTypes.DATE, allowNull: false },
    ends_at:      { type: DataTypes.DATE, allowNull: true },
    capacity:     { type: DataTypes.INTEGER.UNSIGNED, allowNull: true },
    attendee_count: { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 },
    status: {
      type: DataTypes.ENUM('upcoming', 'ongoing', 'completed', 'cancelled'),
      defaultValue: 'upcoming',
    },
    category: { type: DataTypes.STRING(50), allowNull: true },
    is_free:  { type: DataTypes.BOOLEAN, defaultValue: true },
    price:    { type: DataTypes.DECIMAL(10, 2), allowNull: true },
  }, { tableName: 'events' });
};