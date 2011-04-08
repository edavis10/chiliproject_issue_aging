class AgingIssueStatusesController < ApplicationController
  unloadable

  def index
    @issues = Issue.visible.aging_status
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
