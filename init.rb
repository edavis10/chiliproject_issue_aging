require 'redmine'

Redmine::Plugin.register :chiliproject_issue_aging do
  name 'Issue Aging'
  author 'Eric Davis'
  url "https://projects.littlestreamsoftware.com/projects/chiliproject_issue_aging"
  author_url 'http://www.littlestreamsoftware.com'
  description 'Plugin to help manage aging issues.'
  version '0.1.0'

  requires_redmine :version_or_higher => '1.0.0'

  settings(:partial => 'settings/issue_aging',
           :default => {
             'status_warning_days' => '7',
             'status_error_days' => '14'
           })
end

require 'dispatcher'
Dispatcher.to_prepare :chiliproject_issue_aging do
  require_dependency 'issue'
  Issue.send(:include, ChiliprojectIssueAging::Patches::IssuePatch)
end
require 'chiliproject_issue_aging/hooks/view_kanbans_issue_details_hook'
require 'chiliproject_issue_aging/hooks/view_layouts_base_html_head_hook'
