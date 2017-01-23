class CreateRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :records, id:false do |t|
      t.date :date, null:false
      t.text :data, null:false
      t.timestamps
    end
    add_index :records, :date, unique:true
  end
end
