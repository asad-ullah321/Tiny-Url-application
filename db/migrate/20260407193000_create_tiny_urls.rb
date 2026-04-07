class CreateTinyUrls < ActiveRecord::Migration[7.2]
  def change
    create_table :tiny_urls do |t|
      t.string :alias, null: false
      t.string :original_url, null: false

      t.timestamps
    end

    add_index :tiny_urls, :alias, unique: true
  end
end
