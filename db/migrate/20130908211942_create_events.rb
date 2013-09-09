class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|      
      t.string :sport_type
      t.datetime :datetime
      t.string :home
      t.string :visiting
    end
  end
end
