require 'test_helper'

class ListAgingIssuesTest < ActionController::IntegrationTest
  def setup
    configure_plugin
    @user = User.generate!(:password => 'test', :password_confirmation => 'test', :admin => false).reload
    @project = Project.generate!
    @role = Role.generate!(:permissions => [:view_issues])
    User.add_to_project(@user, @project, @role)
    @status = IssueStatus.generate!
    @old_status = IssueStatus.generate!

    @warning_issue1 = Issue.generate_for_project!(@project, :status => @status, :created_on => 30.days.ago)
    @warning_issue2 = Issue.generate_for_project!(@project, :status => @status, :created_on => 30.days.ago)
    @error_issue1 = Issue.generate_for_project!(@project, :status => @status, :created_on => 30.days.ago)
    @error_issue2 = Issue.generate_for_project!(@project, :status => @status, :created_on => 30.days.ago)
    @not_aging_issue = Issue.generate_for_project!(@project, :status => @status, :created_on => 30.days.ago)

    @not_visible_project = Project.generate!
    @not_visible_issue = Issue.generate_for_project!(@not_visible_project, :status => @status, :created_on => 30.days.ago)

    generate_journal_for_status_change(@warning_issue1, 8.days.ago)
    generate_journal_for_status_change(@warning_issue2, 9.days.ago)
    generate_journal_for_status_change(@error_issue1, 16.days.ago)
    generate_journal_for_status_change(@error_issue2, 17.days.ago)
    generate_journal_for_status_change(@not_aging_issue, 1.day.ago)
    generate_journal_for_status_change(@not_visible_issue, 29.days.ago)

    login_as(@user.login, 'test')
    visit_home
  end

  context "browsing to the list of aging issues" do
    should "be successful" do
      visit '/aging_issue_statuses'
      assert_response :success
    end
    
    should "show a list of issues" do
      visit '/aging_issue_statuses'
      assert_response :success

      assert find("table.issues")
      assert find("tr#issue-#{@warning_issue1.id}")
      assert find("tr#issue-#{@warning_issue2.id}")
      assert find("tr#issue-#{@error_issue1.id}")
      assert find("tr#issue-#{@error_issue2.id}")
    end
    
    should "show orange next to warning issues"
    should "show red next to warning issues"
    should "not show issues that aren't aging"
    should "not show issues on hidden projects"
  end
end
