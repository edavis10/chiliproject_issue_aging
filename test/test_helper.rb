# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path


require 'capybara/rails'


def User.add_to_project(user, project, role)
  Member.generate!(:principal => user, :project => project, :roles => [role])
end

module ChiliProjectIntegrationTestHelper
  def login_as(user="existing", password="existing")
    visit "/logout" # Make sure the session is cleared

    visit "/login"
    fill_in 'Login', :with => user
    fill_in 'Password', :with => password
    click_button 'Login'
    assert_response :success
    assert User.current.logged?
  end

  def visit_home
    visit '/'
    assert_response :success
  end

  def visit_project(project)
    visit '/'
    assert_response :success

    click_link 'Projects'
    assert_response :success

    click_link project.name
    assert_response :success
  end

  def visit_issue_page(issue)
    visit '/issues/' + issue.id.to_s
  end

  def visit_issue_bulk_edit_page(issues)
    visit url_for(:controller => 'issues', :action => 'bulk_edit', :ids => issues.collect(&:id))
  end

  
  # Capybara doesn't set the response object so we need to glue this to
  # it's own object but without @response
  def assert_response(code)
    # Rewrite human status codes to numeric
    converted_code = case code
                     when :success
                       200
                     when :missing
                       404
                     when :redirect
                       302
                     when :error
                       500
                     when code.is_a?(Symbol)
                       ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[code]
                     else
                       code
                     end

    assert_equal converted_code, page.status_code
  end

  

end

module ChiliProjectIssueAgingIntegrationTestHelper
  def visit_configuration_panel
    visit_home
    click_link 'Administration'
    assert_response :success

    click_link 'Plugins'
    assert_response :success

    click_link 'Configure'
    assert_response :success
  end
  
end

class ActionController::IntegrationTest
  include ChiliProjectIntegrationTestHelper
  include ChiliProjectIssueAgingIntegrationTestHelper
  include Capybara
  
end

class ActiveSupport::TestCase
  def assert_forbidden
    assert_response :forbidden
    assert_template 'common/403'
  end

  def configure_plugin(configuration_change={})
    Setting.plugin_chiliproject_issue_aging = {
      'status_warning_days' => '7',
      'status_error_days' => '14'
    }.merge(configuration_change)
  end

  def reconfigure_plugin(configuration_change)
    Settings['plugin_chiliproject_issue_aging'] = Setting['plugin_chiliproject_issue_aging'].merge(configuration_change)
  end

  def plugin_configuration
    Setting.plugin_chiliproject_issue_aging
  end

  def generate_journal_for_status_change(issue, created_on=Time.now)
    j = Journal.new(:journalized => issue, :created_on => created_on)
    jd = JournalDetail.new(:property => 'attr',
                           :prop_key => 'status_id',
                           :old_value => @old_status.id,
                           :value => @status.id)
    j.details << jd
    assert j.save

  end
end
