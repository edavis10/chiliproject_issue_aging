module AgingIssueStatusesHelper
  def link_to_project_with_root(project)
    if project.root?
      link_to_project(project)
    else
      "#{link_to_project(project.root)} &#187; #{link_to_project(project)}"
    end
  end

  def number_of_days_ago(date)
    (Date.today - date.to_date).to_i
  end

  def aging_issue_title(issue)
    journal = issue.last_status_change_journal

    if journal
      days_ago = (Date.today - journal.created_on.to_date).to_i
      "#{l(:issue_aging_text_days_ago, :count => days_ago)} (#{ format_time(journal.created_at) })"
    end
  end
end
