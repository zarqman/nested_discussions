class DiscussionFilter < ActiveRecord::Base
  PATTERN_TYPES = %w( ip regex )
  RESPONSES = %w( count disapprove deny blockip )
  RESULTS = {:blockip=>4, :deny=>3, :disapprove=>2, :count=>1, :unknown=>0}

  validates_inclusion_of :pattern_type, :in => PATTERN_TYPES
  validates_inclusion_of :response, :in => RESPONSES
  validates_presence_of :pattern
  validates_numericality_of :positives
  validate :pattern_is_ip, :if=>lambda{|f| f.pattern_type=='ip'}
  
  validates_uniqueness_of :pattern, :scope=>:pattern_type
  
  
  # returns: the strongest of a subset of RESULTS (returning only :deny, :disapprove, :unknown)
  def self.eval_for_spam(ip_addr, *tokens)
    find(:all).inject(:unknown) do |result, fltr|
      # tests below do /not/ short circuit after the first match (or even after the first :deny)
      #   this is to allow positives to be incremented for every match, which is better for statistics
      case fltr.pattern_type
      when 'ip'
        out = fltr.check_ip_and_count(ip_addr)
        (RESULTS[out] > RESULTS[result]) ? out : result
      when 'regex'
        tokens.inject(result) do |res2, token|
          out = fltr.check_token_and_count(token, ip_addr)
          (RESULTS[out] > RESULTS[res2]) ? out : res2
        end
      end
    end
  end


  # protected
  
  # returns: :unknown, :deny, :disapprove
  def check_token_and_count(token, ip_addr)
    return :unknown unless token =~ Regexp.new(pattern, Regexp::IGNORECASE | Regexp::MULTILINE)
    increment! :positives
    return :unknown if response == 'count'
    
    if response == 'blockip'
      self.class.create :pattern=>ip_addr, :response=>'deny'
      # discard if error on create ... most likely a duplicate, which doesn't matter
      return :deny
    end
    response.to_sym
  end
  
  # returns: :unknown, :deny, :disapprove
  def check_ip_and_count(ip_addr)
    return :unknown unless IPAddr.new(pattern).include?( IPAddr.new(ip_addr) )
    increment! :positives
    case response
    when 'count': :unknown
    when 'blockup': :deny
    else
      response.to_sym
    end
  rescue
    return :unknown
  end
  
  
  private
  
  def pattern_is_ip
    errors.add :pattern, 'is not a valid IP or IP block' unless (IPAddr.new(pattern) rescue false)
  end
  
end