require 'test_helper'

class ListAgingIssuesTest < ActionController::IntegrationTest
  def setup
    configure_plugin
    @user = User.generate!(:password => 'test', :password_confirmation => 'test', :admin => false).reload
    @project = Project.generate!.reload
    @project2 = Project.generate!.reload
    @child_project = Project.generate!.reload
    @child_project.set_parent!(@project2)
    @role = Role.generate!(:permissions => [:view_issues])
    User.add_to_project(@user, @project, @role)
    User.add_to_project(@user, @project2, @role)
    User.add_to_project(@user, @child_project, @role)
    @status = IssueStatus.generate!
    @old_status = IssueStatus.generate!
    @closed_status = IssueStatus.generate!(:is_closed => true)
    
    @warning_issue1 = Issue.generate_for_project!(@project, :status => @old_status, :created_on => 30.days.ago)
    change_status(@warning_issue1, @status)
    @warning_issue2 = Issue.generate_for_project!(@project, :status => @old_status, :created_on => 30.days.ago)
    change_status(@warning_issue2, @status)
    @error_issue1 = Issue.generate_for_project!(@project, :status => @old_status, :created_on => 30.days.ago)
    change_status(@error_issue1, @status)
    @error_issue2 = Issue.generate_for_project!(@child_project, :status => @old_status, :created_on => 30.days.ago)
    change_status(@error_issue2, @status)
    @not_aging_issue = Issue.generate_for_project!(@project, :status => @old_status, :created_on => 30.days.ago)
    change_status(@not_aging_issue, @status)
    @closed_issue = Issue.generate_for_project!(@project, :status => @old_status, :created_on => 30.days.ago)
    change_status(@closed_issue, @closed_status)

    @not_visible_project = Project.generate!
    @not_visible_issue = Issue.generate_for_project!(@not_visible_project, :status => @old_status, :created_on => 30.days.ago)
    change_status(@not_visible_issue, @status)

    update_journal_for_status_change(@warning_issue1, 8.days.ago)
    update_journal_for_status_change(@warning_issue2, 9.days.ago)
    update_journal_for_status_change(@error_issue1, 16.days.ago)
    update_journal_for_status_change(@error_issue2, 17.days.ago)
    update_journal_for_status_change(@not_aging_issue, 1.day.ago)
    update_journal_for_status_change(@not_visible_issue, 29.days.ago)
    update_journal_for_status_change(@closed_issue, 29.days.ago)

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

    should "group issues by the root project" do
      visit '/aging_issue_statuses'
      assert_response :success

      assert find("table.issues.project-#{@project2.id} tr#issue-#{@error_issue2.id}")
    end
    
    should "show orange next to warning issues" do
      visit '/aging_issue_statuses'
      assert_response :success

      assert has_css?("tr#issue-#{@warning_issue1.id} td.aging.warning-state")
      assert has_css?("tr#issue-#{@warning_issue2.id} td.aging.warning-state")
    end
    
    should "show red next to warning issues" do
      visit '/aging_issue_statuses'
      assert_response :success

      assert has_css?("tr#issue-#{@error_issue1.id} td.aging.error-state")
      assert has_css?("tr#issue-#{@error_issue2.id} td.aging.error-state")
    end

    should "not show issues that aren't aging" do
      visit '/aging_issue_statuses'
      assert_response :success

      assert has_no_css?("tr#issue-#{@not_aging_issue.id}")
    end
    
    should "not show issues on hidden projects" do
      visit '/aging_issue_statuses'
      assert_response :success

      assert has_no_css?("tr#issue-#{@not_visible_issue.id}")
    end

    should "not show closed issues" do
      visit '/aging_issue_statuses'
      assert_response :success

      assert has_no_css?("tr#issue-#{@closed_issue.id}")
    end
  end
end
