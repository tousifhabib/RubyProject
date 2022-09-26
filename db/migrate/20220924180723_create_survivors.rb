# frozen_string_literal: true

class CreateSurvivors < ActiveRecord::Migration[7.0]
  def change
    create_table :survivors do |t|
      t.string :name, null: false
      t.integer :age, null: false
      t.string :gender, null: false
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.integer :water, default: 0, null: true
      t.integer :soup, default: 0, null: true
      t.integer :firstAid, default: 0, null: true
      t.integer :ak47, default: 0, null: true
      t.integer :infectionCount, default: 0, null: false
      t.boolean :infected, default: false, null: false

      t.timestamps
    end
  end
end
