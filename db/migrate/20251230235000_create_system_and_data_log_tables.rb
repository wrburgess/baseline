class CreateSystemAndDataLogTables < ActiveRecord::Migration[8.1]
  def change
    create_table :data_logs do |t|
      t.references :loggable, null: false, polymorphic: true, index: false
      t.references :user, foreign_key: true
      t.string :operation
      t.text :note
      t.jsonb :meta
      t.jsonb :original_data

      t.timestamps
    end
    add_index :data_logs, %i[loggable_type loggable_id], name: "index_data_logs_on_loggable"

    create_table :system_groups do |t|
      t.string :name
      t.string :abbreviation
      t.string :description
      t.text :notes

      t.timestamps
    end

    create_table :system_roles do |t|
      t.string :name
      t.string :abbreviation
      t.string :description
      t.text :notes

      t.timestamps
    end

    create_table :system_permissions do |t|
      t.string :name
      t.string :abbreviation
      t.string :description
      t.text :notes
      t.string :resource
      t.string :operation

      t.timestamps
    end

    create_table :system_group_system_roles do |t|
      t.references :system_group, foreign_key: true
      t.references :system_role, foreign_key: true

      t.timestamps
    end

    create_table :system_group_users do |t|
      t.references :system_group, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end

    create_table :system_role_system_permissions do |t|
      t.references :system_role, foreign_key: true
      t.references :system_permission, foreign_key: true

      t.timestamps
    end
  end
end
