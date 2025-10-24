class AddExpirationToSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :expires_at, :datetime
    add_column :sessions, :last_activity_at, :datetime

    add_index :sessions, :expires_at
    add_index :sessions, [ :user_id, :last_activity_at ]

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE sessions
          SET last_activity_at = COALESCE(last_activity_at, created_at),
              expires_at = COALESCE(expires_at, datetime(created_at, '+30 days'))
        SQL
      end
    end

    change_column_null :sessions, :expires_at, false
    change_column_null :sessions, :last_activity_at, false
  end
end
