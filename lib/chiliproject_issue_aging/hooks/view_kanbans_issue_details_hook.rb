module ChiliprojectIssueAging
  module Hooks
    class ViewKanbansIssueDetailsHook < Redmine::Hook::ViewListener
      def view_kanbans_issue_details(context={})
        issue = context[:issue]

        aging_status = issue.aging_status
        journal = issue.last_status_change_journal
        
        if aging_status && journal
          time_ago = (Date.today - journal.created_on.to_date).to_i

          if aging_status == :warning
            css_class = 'aging warning-state'
          elsif aging_status == :error
            css_class = 'aging error-state'
          end
          
          return content_tag(:span,
                             time_ago,
                             {
                               :title => l(:issue_aging_text_days_ago, :count => time_ago),
                               :class => css_class
                             })

        else
          return ''
        end
        
      end
    end
  end
end
