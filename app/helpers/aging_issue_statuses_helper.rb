module AgingIssueStatusesHelper
  def link_to_project_with_root(project)
    if project.root?
      link_to_project(project)
    else
      "#{link_to_project(project.root)} &#187; #{link_to_project(project)}"
    end
  end
end
