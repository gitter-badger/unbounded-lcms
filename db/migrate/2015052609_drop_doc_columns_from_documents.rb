class DropDocColumnsFromDocuments < ActiveRecord::Migration
  def change
    change_table :documents do |t|
      t.remove 'doc_id'
      t.remove 'doc_schema_format'
      t.remove 'doc_created_at'
    end
  end
end
