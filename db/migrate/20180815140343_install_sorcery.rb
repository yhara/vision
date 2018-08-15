class InstallSorcery < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email,            :null => false
      t.string :crypted_password
      t.string :salt

      t.timestamps                :null => false
    end
    add_index :users, :email, unique: true

    add_column :users, :remember_me_token, :string, :default => nil
    add_column :users, :remember_me_token_expires_at, :datetime, :default => nil
    add_index :users, :remember_me_token
  end
end
