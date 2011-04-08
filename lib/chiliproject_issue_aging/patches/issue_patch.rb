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
        def aging_status_warning?
          aging_status == :warning
        end

        def aging_status_error?
          aging_status == :error
        end
        
        def aging_status
          return nil if journals.empty?

          if Setting.plugin_chiliproject_issue_aging['status_error_days'].present?
            error_days = Setting.plugin_chiliproject_issue_aging['status_error_days'].to_i
          end

          if Setting.plugin_chiliproject_issue_aging['status_warning_days'].present?
            warning_days = Setting.plugin_chiliproject_issue_aging['status_warning_days'].to_i
          end

          return nil if error_days.nil? && warning_days.nil? # Short circuit if no days configured
          
          c = ARCondition.new
          c.add "#{JournalDetail.table_name}.property = 'attr'"
          c.add "#{JournalDetail.table_name}.prop_key = 'status_id'"
          c.add ["#{JournalDetail.table_name}.value = ?", status_id.to_s] # value is converted to String
          status_change_journal = journals.first(:include => :details,
                                                 :order => 'created_on DESC',
                                                 :conditions => c.conditions)
          if status_change_journal

            if error_days.present? && status_change_journal.created_on <= error_days.days.ago
              return :error
            end


            if warning_days.present? && status_change_journal.created_on <= warning_days.days.ago
              return :warning
            end
          end
        end
        
      end
    end
  end
end
