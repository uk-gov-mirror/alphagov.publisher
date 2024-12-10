class CreatePart < ActiveRecord::Migration[7.1]
  def change
    create_table :parts do |t|
      t.integer :order
      t.string :title
      t.string :body
      t.string :slug
      t.datetime :created_at, default: Time.zone.now
    end
  end
end
