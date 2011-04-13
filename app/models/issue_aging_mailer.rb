class IssueAgingMailer < Mailer
  def aging_issue_status_report(user, aging_issues)
    recipients user.mail
    subject l(:issue_aging_text_title)
    body :issues => aging_issues
    render_multipart('aging_issue_status_report', body)
  end
  
end
