const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  return sequelize.define('Post', {
    id: { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
    user_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
    content: { type: DataTypes.TEXT, allowNull: false, validate: { len: [1, 5000] } },
    media_urls: {
 type: DataTypes.JSON, // array of URLs
      allowNull: true,
      defaultValue: [],
    },
    tagged_users: {
 type: DataTypes.JSON, // array of {id, name, username}
      allowNull: true,
      defaultValue: [],
    },
    post_type: {
      type: DataTypes.ENUM('text', 'image', 'video', 'link', 'event_share', 'market_share'),
      defaultValue: 'text',
    },
    visibility: {
      type: DataTypes.ENUM('public', 'connections', 'private'),
      defaultValue: 'public',
    },
    reaction_count: { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 },
    comment_count:  { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 },
    share_count:    { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 },
    is_edited:      { type: DataTypes.BOOLEAN, defaultValue: false },
    is_deleted:     { type: DataTypes.BOOLEAN, defaultValue: false },
  }, { tableName: 'posts' });
};
