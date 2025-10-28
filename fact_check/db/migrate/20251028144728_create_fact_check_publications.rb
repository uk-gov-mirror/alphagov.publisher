class CreateFactCheckPublications < ActiveRecord::Migration[8.1]
  def change
    create_table :fact_check_publications do |t|
      t.string :title

      t.timestamps
    end
  end
end
