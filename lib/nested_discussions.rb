module ActiveRecord
  module Acts
    module Discussable

      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
      
        def acts_as_discussable(*args)
          self.class_eval do
            has_one :discussion, :as=>:discussable

            include ActiveRecord::Acts::Discussable::InstanceMethods
          end
        end
        
      end
      
      module InstanceMethods
      
        def discussion_status
          discussion ? (discussion.open? ? 'open' : 'closed') : 'disabled'
        end

        def discussion_status=(val)
          case val
          when 'open'
            new_record? ? build_discussion : create_discussion unless discussion
            discussion.open = true
            discussion.save unless new_record?
          when 'closed'
            new_record? ? build_discussion : create_discussion unless discussion
            discussion.open = false
            discussion.save unless new_record?
          when 'disabled'
            if discussion
              raise 'Cannot remove discussion with comments' if discussion.comments.reload.size > 0
              discussion.destroy
            end
          else
            raise ArgumentError, 'Unknown value to discussion_status='
          end
        end
      
      end
      
    end
  end
end