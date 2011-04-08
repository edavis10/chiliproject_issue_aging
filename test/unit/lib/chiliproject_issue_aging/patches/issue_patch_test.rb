require File.dirname(__FILE__) + '/../../../../test_helper'

class ChiliprojectIssueAging::Patches::IssueTest < ActionController::TestCase

  def setup
    configure_plugin
  end

  def generate_journal_for_status_change(created_on=Time.now)
    j = Journal.new(:journalized => @issue, :created_on => created_on)
    jd = JournalDetail.new(:property => 'attr',
                           :prop_key => 'status_id',
                           :old_value => @old_status.id,
                           :value => @status.id)
    j.details << jd
    assert j.save

  end
  
  context "Issue#aging_status" do
    setup do
      @project = Project.generate!
      @status = IssueStatus.generate!
      @old_status = IssueStatus.generate!
      @issue = Issue.generate_for_project!(@project, :status => @status, :created_on => 30.days.ago)
    end
    
    should "return nil when status has been less than the warning" do
      generate_journal_for_status_change(Time.now)
      assert_equal nil, @issue.aging_status
    end
    
    should "return :warning when status has been more than the warning but less than error" do
      generate_journal_for_status_change(8.days.ago)
      assert_equal :warning, @issue.aging_status
    end
    
    should "return :error when status has been more than the warning and more than error"
  end

  context "Issue#aging_status_warning?" do
    should "return false when status has been less than the warning"
    should "return true when status has been more than the warning but less than error"
    should "return false when status has been more than the warning and more than error"
  end

  context "Issue#aging_status_warning?" do
    should "return false when status has been less than the warning"
    should "return false when status has been more than the warning but less than error"
    should "return true when status has been more than the warning and more than error"
  end
end
