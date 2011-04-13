namespace :issue_aging do
  desc <<-END_DESC
Send issue aging reports via email.

Available options:

  * users => list of user ids who should get the report (defaults to all active users)

Examples:
  rake issue_aging:send_issue_aging_report
  rake issue_aging:send_issue_aging_report users="1,3,5"
END_DESC
  task :send_issue_aging_report => :environment do
    options = {}
    options[:users] = (ENV['users'] || '').split(',').each(&:strip!)

    IssueAging.aging_issue_status_email(options)
  end
end
