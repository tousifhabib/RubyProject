class CreateSurvivors < ActiveRecord::Migration[7.0]
  def change
    create_table :survivors do |t|
      t.string :name
      t.integer :age
      t.string :gender
      t.float :latitude
      t.float :longitude
      t.integer :water
      t.integer :soup
      t.integer :firstAid
      t.integer :ak47

      t.timestamps
    end
  end
end
