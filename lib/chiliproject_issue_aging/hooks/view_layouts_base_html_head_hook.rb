module ChiliprojectIssueAging
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return <<CSS
<!-- chiliproject_issue_aging plugin -->
<style type="text/css">
.aging.warning-state { background-color: #FDBF3B; }
.aging.error-state { background-color: #dd0000; color: #FFFFFF; }
#kanban .aging { padding: 2px; border: solid 1px #D5D5D5; font-size: 10px; }
/* color on white */
#kanban .aging.warning-state {background-color: white; color: #FDBF3B; }
#kanban .aging.error-state {background-color: white; color: #dd0000; }
</style> 
<!-- chiliproject_issue_aging plugin -->
CSS
      end
    end
  end
end
