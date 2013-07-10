class AddNonstandardToActivities < ActiveRecord::Migration
  def change
    change_table :queued_tasks do |t|
      t.string :nonstandard
    end
  end
end
