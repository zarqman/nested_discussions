class NestedDiscussionsMigration < ActiveRecord::Migration
  def self.up
    create_table :discussions, :force => true do |t|
      t.integer   :discussable_id, :null=>false, :references=>nil
      t.string    :discussable_type, :null=>false
      t.boolean   :open, :default=>true, :null=>false
      t.timestamps
    end
      
    add_index :discussions, [:discussable_id, :discussable_type]
    
    create_table :comments, :force => true do |t|
      t.integer   :discussion_id, :null=>false
      t.integer   :parent_id
      t.integer   :lft
      t.integer   :rgt
      t.text      :body
      t.integer   :author_id, :references=>nil
      t.string    :author_name, :limit=>50
      t.string    :author_email, :limit=>100
      t.string    :author_url, :limit=>100
      t.string    :author_ip, :limit=>50
      t.boolean   :email_on_reply, :default=>false, :null=>false
      # approval_state: 2=yes,manual, 1=yes,auto, 0=no,auto, -1=no,manual, -2=no,deleted ... suggested default: 1 or 0
      t.integer   :approval_state, :default=>1, :null=>false
      t.datetime  :created_at
    end
      
    add_index :comments, :discussion_id
    
    create_table :discussion_filters, :force => true do |t|
      t.string    :pattern_type, :limit=>20, :default=>'ip', :null=>false
      t.string    :pattern, :null=>false
      t.string    :response, :limit=>20, :default=>'count', :null=>false
      t.integer   :positives, :default=>0, :null=>false
      t.timestamps
    end
  end
  
  def self.down
    drop_table :discussion_filters
    drop_table :comments
    drop_table :discussions
  end
end
