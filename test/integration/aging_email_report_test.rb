require 'test_helper'

class AgingEmailReportTest < ActionController::IntegrationTest
  def setup
    configure_plugin
    @user = User.generate!(:password => 'test', :password_confirmation => 'test', :admin => false).reload
    @user2 = User.generate!(:password => 'test', :password_confirmation => 'test', :admin => false).reload
    @project = Project.generate!
    @role = Role.generate!(:permissions => [:view_issues])
    User.add_to_project(@user, @project, @role)
    User.add_to_project(@user2, @project, @role)

    @status = IssueStatus.generate!
    @old_status = IssueStatus.generate!
    @closed_status = IssueStatus.generate!(:is_closed => true)
    
    @warning_issue_for_user1 = Issue.generate_for_project!(@project, :assigned_to => @user, :status => @old_status, :created_on => 30.days.ago)
    change_status(@warning_issue_for_user1, @status)
    @warning_issue_for_user2 = Issue.generate_for_project!(@project, :assigned_to => @user2, :status => @old_status, :created_on => 30.days.ago)
    change_status(@warning_issue_for_user2, @status)
    @error_issue_for_user1 = Issue.generate_for_project!(@project, :assigned_to => @user, :status => @old_status, :created_on => 30.days.ago)
    change_status(@error_issue_for_user1, @status)
    @error_issue_for_user2 = Issue.generate_for_project!(@project, :assigned_to => @user2, :status => @old_status, :created_on => 30.days.ago)
    change_status(@error_issue_for_user2, @status)
    @not_aging_issue_for_user1 = Issue.generate_for_project!(@project, :assigned_to => @user, :status => @old_status, :created_on => 30.days.ago)
    change_status(@not_aging_issue_for_user1, @status)
    @closed_issue_for_user1 = Issue.generate_for_project!(@project, :assigned_to => @user, :status => @old_status, :created_on => 30.days.ago)
    change_status(@closed_issue_for_user1, @closed_status)

    update_journal_for_status_change(@warning_issue_for_user1, 8.days.ago)
    update_journal_for_status_change(@warning_issue_for_user2, 9.days.ago)
    update_journal_for_status_change(@error_issue_for_user1, 16.days.ago)
    update_journal_for_status_change(@error_issue_for_user2, 17.days.ago)
    update_journal_for_status_change(@not_aging_issue_for_user1, 1.day.ago)
    update_journal_for_status_change(@closed_issue_for_user1, 29.days.ago)
  end

  should "send an email to each user who has aging issues assigned" do
    ActionMailer::Base.deliveries.clear

    assert_difference('ActionMailer::Base.deliveries.size', 2) do
      IssueAging.aging_issue_status_email
    end
    
  end

  should "list all aging issues in one email" do
    IssueAging.aging_issue_status_email

    assert_sent_email do |mail|
      mail.bcc.include?(@user.mail) &&
        mail.body.include?(@warning_issue_for_user1.subject) &&
        mail.body.include?(@error_issue_for_user1.subject) &&
        !mail.body.include?(@not_aging_issue_for_user1.subject) &&
        !mail.body.include?(@closed_issue_for_user1.subject)
    end
    
  end
  

  should "allow limiting the users emailed by id" do
    ActionMailer::Base.deliveries.clear

    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      IssueAging.aging_issue_status_email(:users => [@user2.id])
    end

    assert_sent_email do |mail|
      mail.bcc.include?(@user2.mail)
    end
  end
  
end
