module ChiliprojectIssueAging
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def aging_status
          return nil if journals.empty?
          
          c = ARCondition.new
          c.add "#{JournalDetail.table_name}.property = 'attr'"
          c.add "#{JournalDetail.table_name}.prop_key = 'status_id'"
          c.add ["#{JournalDetail.table_name}.value = ?", status_id.to_s] # value is converted to String
          status_change_journal = journals.first(:include => :details,
                                                 :order => 'created_on DESC',
                                                 :conditions => c.conditions)
          if status_change_journal
            if Setting.plugin_chiliproject_issue_aging['status_error_days'].present?
              error_days = Setting.plugin_chiliproject_issue_aging['status_error_days'].to_i
              if status_change_journal.created_on <= error_days.days.ago
                return :error
              end
            end

            if Setting.plugin_chiliproject_issue_aging['status_warning_days'].present?
              warning_days = Setting.plugin_chiliproject_issue_aging['status_warning_days'].to_i
              if status_change_journal.created_on > warning_days.days.ago
                # Status change is newer than warning
                return nil
              elsif status_change_journal.created_on <= warning_days.days.ago
                return :warning
              end
              
            end
          end
          return nil
        end
        
      end
    end
  end
end
