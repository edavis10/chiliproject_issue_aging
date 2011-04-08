require 'redmine'

Redmine::Plugin.register :chiliproject_issue_aging do
  name 'Issue Aging'
  author 'Eric Davis'
  url "https://projects.littlestreamsoftware.com/projects/chiliproject_issue_aging"
  author_url 'http://www.littlestreamsoftware.com'
  description 'Plugin to help manage aging issues.'
  version '0.1.0'

  requires_redmine :version_or_higher => '1.0.0'
end
