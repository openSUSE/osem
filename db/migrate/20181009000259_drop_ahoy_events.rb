class DropAhoyEvents < ActiveRecord::Migration[5.0]
  def up
    remove_index :visits, [:visit_token]
    remove_index :ahoy_events, [:name, :time]

    drop_table :targets
    drop_table :campaigns
    drop_table :visits
    drop_table :ahoy_events
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
