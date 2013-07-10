# Migration responsible for creating a table with queued_tasks
class CreateQueuedTasks < ActiveRecord::Migration
  # Create table
  def self.up
    create_table :queued_tasks do |t|
      t.belongs_to :actor,      :polymorphic => true
      t.belongs_to :act_object, :polymorphic => true
      t.belongs_to :act_target, :polymorphic => true

      t.string  :verb
      t.string  :description
      t.string  :options
      t.string  :bond_type

      t.time :publish_on
      t.string :state

      t.timestamps
    end

    add_index :queued_tasks, [:verb]
    add_index :queued_tasks, [:actor_id, :actor_type]
    add_index :queued_tasks, [:act_object_id, :act_object_type]
    add_index :queued_tasks, [:act_target_id, :act_target_type]
  end
  # Drop table
  def self.down
    drop_table :queued_tasks
  end
end
