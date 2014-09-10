class CreateScreens < ActiveRecord::Migration
  def change
    create_table :screens do |t|
      t.text :text

      t.timestamps
    end
  end
end
