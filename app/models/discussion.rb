class Discussion < ActiveRecord::Base
  
  has_many :comments
  belongs_to :discussable, :polymorphic=>true
  
  validates_presence_of :discussable_id, :discussable_type
  
  attr_accessible :open

  def comments_count
    @comments_count ||= comments.approved.count
  end
end
