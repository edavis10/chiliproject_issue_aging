class AgingIssueStatusesController < ApplicationController
  unloadable

  def index
    @issues = Issue.visible.open.aging_status
    # Convert [issues] to a sorted [[project, [issues],..]
    issues_grouped_and_sorted_by_project = @issues.group_by do |issue|
      issue.project.root
    end.sort_by do |project, issues|
      project.name
    end
    @issues_by_project = sort_issues(issues_grouped_and_sorted_by_project)
  end

  protected
  def aging_issue_css(issue)
    status = issue.aging_status
    return 'aging' if status.nil?
    return 'aging warning-state' if status == :warning
    return 'aging error-state' if status == :error
  end
  helper_method :aging_issue_css

  private

  def sort_issues(project_issues)
    project_issues.collect do |project_issue_data|
      sorted_issues = project_issue_data.last.sort do |issue_a, issue_b|
        if Setting.respond_to?(:plugin_redmine_kanban)
          sort_issues_by_assigned_to_and_kanban_order(issue_a, issue_b)
        else
          sort_issues_by_assigned_to_and_status_position(issue_a, issue_b)
        end
      end
      [project_issue_data.first, sorted_issues]
    end
  end

  # Sort by assigned_to and then status, using an array for subsorts
  def sort_issues_by_assigned_to_and_status_position(issue_a, issue_b)
    [(issue_a.assigned_to_id || 0), issue_a.status.position] <=>
      [(issue_b.assigned_to_id || 0), issue_b.status.position]
  end

  def sort_issues_by_assigned_to_and_kanban_order(issue_a, issue_b)
    ordered_status_ids =
      [
       Setting.plugin_redmine_kanban.try('[]','panes').try('[]','testing').try('[]','status'),
       Setting.plugin_redmine_kanban.try('[]','panes').try('[]','active').try('[]','status'),
       Setting.plugin_redmine_kanban.try('[]','panes').try('[]','selected').try('[]','status')
      ].compact.collect(&:to_i)

    IssueStatus.all(:order => 'position ASC').each do |issue_status|
      next if ordered_status_ids.include?(issue_status)
      ordered_status_ids << issue_status.id
    end
    [
     (issue_a.assigned_to_id || 0),
     ordered_status_ids.index(issue_a.status_id)
    ] <=>
      [
       (issue_b.assigned_to_id || 0),
       ordered_status_ids.index(issue_b.status_id)
      ]

  end
end
