require 'ar_condition'

module ChiliprojectIssueAging
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          named_scope :aging_status, lambda {
            # Find the minimum number of days to check against
            status_journal_created_before = nil
            if Setting.plugin_chiliproject_issue_aging['status_warning_days'].present?
              status_journal_created_before = Setting.plugin_chiliproject_issue_aging['status_warning_days'].to_i
            end

            if Setting.plugin_chiliproject_issue_aging['status_error_days'].present? &&
              status_journal_created_before >= Setting.plugin_chiliproject_issue_aging['status_error_days'].to_i
              status_journal_created_before = Setting.plugin_chiliproject_issue_aging['status_error_days'].to_i
            end

            if status_journal_created_before
              c = ARCondition.new
              c.add ["#{Journal.table_name}.changes LIKE(?)", '%status_id%']
              c.add "#{Journal.table_name}.version > 1"
              c.add ["#{Journal.table_name}.created_at <= ?", status_journal_created_before.days.ago]

              return {
                :include => :journals,
                :order => "#{Journal.table_name}.created_at ASC",
                :conditions => c.conditions
              }
            else
              # empty set
              return { :conditions => "0=1" }
            end
          }
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        # Has the issue entered the aging warning state for it's status?
        #
        # @return [Bool]
        def aging_status_warning?
          aging_status == :warning
        end

        # Has the issue entered the aging error state for it's status?
        #
        # @return [Bool]
        def aging_status_error?
          aging_status == :error
        end
        
        # Checks if the issue has been aging at it's current status and triggers
        # an aging state
        #
        # @return [nil]
        # @return [Symbol, :warning] the issue has aged into the warning state
        # @return [Symbol, :error] the issue has aged into the error state
        def aging_status
          return nil if journals.empty?
          return nil if closed?

          if Setting.plugin_chiliproject_issue_aging['status_error_days'].present?
            error_days = Setting.plugin_chiliproject_issue_aging['status_error_days'].to_i
          end

          if Setting.plugin_chiliproject_issue_aging['status_warning_days'].present?
            warning_days = Setting.plugin_chiliproject_issue_aging['status_warning_days'].to_i
          end

          return nil if error_days.nil? && warning_days.nil? # Short circuit if no days configured
          
          status_change_journal = last_status_change_journal
          
          if status_change_journal

            if error_days.present? && status_change_journal.created_on <= error_days.days.ago
              return :error
            end


            if warning_days.present? && status_change_journal.created_on <= warning_days.days.ago
              return :warning
            end
          end
        end

        def last_status_change_journal
          c = ARCondition.new
          c.add ["#{Journal.table_name}.changes LIKE(?)", '%status_id%']
          # Select using Ruby because of the serialized attributes
          journals.all(:order => 'created_at DESC',
                       :conditions => c.conditions).detect {|journal|
            journal.changes["status_id"].present? &&
            journal.changes["status_id"].last == status_id
          }
        end
        
      end
    end
  end
end
