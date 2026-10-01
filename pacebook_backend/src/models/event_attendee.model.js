const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  return sequelize.define('EventAttendee', {
    id:       { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
    event_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    user_id:  { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    status: {
      type: DataTypes.ENUM('going', 'interested', 'not_going'),
      defaultValue: 'going',
    },
    registered_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  }, {
    tableName: 'event_attendees',
    indexes: [{ unique: true, fields: ['event_id', 'user_id'] }],
  });
};