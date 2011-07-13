class AgingIssueStatusesController < ApplicationController
  unloadable

  def index
    @issues = Issue.visible.open.aging_status
    # Convert [issues] to a sorted [[project, [issues],..]
    @issues_by_project = @issues.group_by do |issue|
      issue.project.root
    end.sort_by do |project, issues|
      project.name
    end
  end

  protected
  def aging_issue_css(issue)
    status = issue.aging_status
    return 'aging' if status.nil?
    return 'aging warning-state' if status == :warning
    return 'aging error-state' if status == :error
  end
  helper_method :aging_issue_css
end
