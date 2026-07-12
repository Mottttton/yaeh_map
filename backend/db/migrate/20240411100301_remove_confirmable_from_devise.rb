class RemoveConfirmableFromDevise < ActiveRecord::Migration[6.1]
  def up
    remove_index :accounts, :confirmation_token
    remove_column :accounts, :confirmation_token
    remove_column :accounts, :confirmed_at
    remove_column :accounts, :confirmation_sent_at
    remove_column :accounts, :unconfirmed_email
  end
  def down
    add_column :accounts, :confirmation_token, :string
    add_column :accounts, :confirmed_at, :datetime
    add_column :accounts, :confirmation_sent_at, :datetime
    add_column :accounts, :unconfirmed_email, :string
    add_index :accounts, :confirmation_token, unique: true
    Account.update_all confirmed_at: DateTime.now
  end
end
