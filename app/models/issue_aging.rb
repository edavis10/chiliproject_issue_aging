class IssueAging
  # Deliver the aging issue status report via email
  # @param [Hash] options options
  # @option options [Array] :users array of users or user ids to send email to
  def self.aging_issue_status_email(options={})
    only_users = options[:users]
    if only_users.present?
      users = only_users.collect do |u|
        case
        when u.is_a?(User)
          u
        when u.is_a?(String)
          User.find(u)
        when u.is_a?(Integer)
          User.find(u)
        end
      end
    else
      users = User.active
    end

    users.each do |user|
      issues = Issue.visible(user).open.aging_status.all(:conditions => {:assigned_to_id => user.id})
      if issues.present?
        IssueAgingMailer.deliver_aging_issue_status_report(user, issues)
      end
    end
    
  end
end
