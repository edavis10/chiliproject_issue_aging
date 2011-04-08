require File.dirname(__FILE__) + '/../../../test_helper'

class ChiliprojectIssueAging::Hooks::ViewLayoutsBaseHtmlHeadTest < ActionController::IntegrationTest
  include Redmine::Hook::Helper

  context "#view_layouts_base_html_head" do
    setup do
    end

    should "be tested"
  end
end
