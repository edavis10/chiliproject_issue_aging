class AgingIssueStatusesController < ApplicationController
  unloadable

  def index
    @issues = Issue.visible.aging_status
  end
  
end
