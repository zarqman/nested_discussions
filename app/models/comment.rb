class Comment < ActiveRecord::Base
  # 2=yes,manual, 1=yes,auto, 0=no,auto, -1=no,manual, -2=no,deleted ... suggested default: 1 or 0
  APPROVAL_STATES = {2=>'yes (reviewed)', 1=>'yes (auto)', 0=>'no (auto)', -1=>'no (reviewed)', -2=>'deleted'}
  
  before_create :evaluate_spam
  
  acts_as_nested_set :scope=>:discussion
  default_scope :order=>'lft'
  
  belongs_to :discussion
  
  validates_presence_of :discussion_id
  validates_length_of :body, :maximum => 4000, :message => 'of comment may be a maximum of 4000 characters', :allow_nil=>true
  validates_length_of :body, :minimum => 10
  validates_length_of :author_name, :within => 2..50
  validates_format_of :author_name, :with => /^[^<>]*$/, :allow_nil=>true
  validates_length_of :author_email, :maximum => 100, :allow_nil=>true
  validates_format_of :author_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i#, :allow_nil => true
  validates_length_of :author_url, :maximum => 100, :allow_nil=>true
  validates_format_of :author_url, :message => ": URL must begin with 'http://' and be a legal URL.", :with => /^(https?:\/\/[a-z0-9._&\/?=,;:+#]+)?$/i, :allow_nil => true
  
  # preferred attr_accessible, but that seems to be broken by better_nested_set and kin
  attr_protected :discussion_id, :author_id, :author_ip, :approval_state, :created_at
  
  
  named_scope :approved, :conditions=>["approval_state >= 1"]
  named_scope :visible_for_feed, :conditions=>['approval_state >= 0']
  named_scope :visible_for_admin, :conditions=>["approval_state >= -1"] # arguably could be >= 0 (but would make it difficult for correcting a mistake)
  
  
  def get_emails_for_notify(exclude=self.author_email)
    em = []
    if email_on_reply && approved?
      em << author_email
    end
    if parent
      em += parent.get_emails_for_notify(exclude)
    end
    em -= [exclude]
    em.compact.uniq
  end
  
  def approved?
    approval_state >= 1
  end
  
  def visible_to_admin?
    approval_state >= -1
  end
  
  
  private
  
  def evaluate_spam
    self.approval_state = 0 and return if author_ip.blank?
    case DiscussionFilter.eval_for_spam(author_ip, body, author_name, author_email, author_url)
    when :unknown
      self.approval_state = 1
    when :disapprove
      self.approval_state = 0
    when :deny
      errors.add_to_base 'Comment block by spam filter'
      return false
    end
  end
  
end