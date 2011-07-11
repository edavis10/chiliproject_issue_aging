require File.dirname(__FILE__) + '/../../../../test_helper'

class ChiliprojectIssueAging::Patches::IssueTest < ActionController::TestCase

  def setup
    configure_plugin
    @project = Project.generate!
    @status = IssueStatus.generate!
    @old_status = IssueStatus.generate!
    @issue = Issue.generate_for_project!(@project, :status => @old_status, :created_on => 30.days.ago)
    change_status(@issue, @status)
  end

  context "Issue#aging_status" do
    should "return nil when status has been less than the warning" do
      update_journal_for_status_change(@issue, Time.now)
      assert_equal nil, @issue.aging_status
    end
    
    should "return :warning when status has been more than the warning but less than error" do
      update_journal_for_status_change(@issue, 8.days.ago)
      assert_equal :warning, @issue.aging_status
    end
    
    should "return :error when status has been more than the warning and more than error" do
      update_journal_for_status_change(@issue, 20.days.ago)
      assert_equal :error, @issue.aging_status
    end

    should "return nil when the issue is closed" do
      @status = IssueStatus.generate!(:is_closed => true)
      @issue.update_attribute(:status_id, @status.id)
      @issue.reload
      update_journal_for_status_change(@issue, 20.days.ago)

      assert_equal nil, @issue.aging_status
    end
  end

  context "Issue#aging_status_warning?" do
    should "return false when status has been less than the warning" do
      update_journal_for_status_change(@issue, Time.now)
      assert_equal false, @issue.aging_status_warning?
    end

    should "return true when status has been more than the warning but less than error" do
      update_journal_for_status_change(@issue, 8.days.ago)
      assert_equal true, @issue.aging_status_warning?
    end

    should "return false when status has been more than the warning and more than error" do
      update_journal_for_status_change(@issue, 20.days.ago)
      assert_equal false, @issue.aging_status_warning?
    end

    should "return false when issue is closed" do
      @status = IssueStatus.generate!(:is_closed => true)
      @issue.update_attribute(:status_id, @status.id)
      @issue.reload
      update_journal_for_status_change(@issue, 8.days.ago)

      assert_equal false, @issue.aging_status_warning?
    end
  end

  context "Issue#aging_status_error?" do
    should "return false when status has been less than the warning" do
      update_journal_for_status_change(@issue, Time.now)
      assert_equal false, @issue.aging_status_error?
    end

    should "return false when status has been more than the warning but less than error" do
      update_journal_for_status_change(@issue, 8.days.ago)
      assert_equal false, @issue.aging_status_error?
    end

    should "return true when status has been more than the warning and more than error" do
      update_journal_for_status_change(@issue, 20.days.ago)
      assert_equal true, @issue.aging_status_error?
    end

    should "return false when issue is closed" do
      @status = IssueStatus.generate!(:is_closed => true)
      @issue.update_attribute(:status_id, @status.id)
      @issue.reload
      update_journal_for_status_change(@issue, 20.days.ago)

      assert_equal false, @issue.aging_status_error?
    end
  end
end
