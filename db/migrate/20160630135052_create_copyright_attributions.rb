class CreateCopyrightAttributions < ActiveRecord::Migration
  def change
    create_table :copyright_attributions do |t|
      t.references :curriculum, index: true, null: false
      t.string :disclaimer
      t.string :value, null: false

      t.timestamps null: false

      t.foreign_key :curriculums, on_delete: :cascade
    end
  end
end
