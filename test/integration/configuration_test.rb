require 'test_helper'

class ConfigurationTest < ActionController::IntegrationTest
  def setup
    @user = User.generate!(:password => 'test', :password_confirmation => 'test', :admin => true)
  end

  should "add a plugin configuration panel" do
    login_as(@user.login, 'test')
    visit_home
    click_link 'Administration'
    assert_response :success

    click_link 'Plugins'
    assert_response :success

    click_link 'Configure'
    assert_response :success
  end

  should "be able to configure the status warning days" do
    login_as(@user.login, 'test')
    visit_configuration_panel

    fill_in "Number of days before an issue enters the warning state", :with => '30'
    click_button 'Apply'

    assert_equal '30', plugin_configuration['status_warning_days']
  end

  should "be able to configure the status error days" do
    login_as(@user.login, 'test')
    visit_configuration_panel

    fill_in "Number of days before an issue enters the error state", :with => '90'
    click_button 'Apply'

    assert_equal '90', plugin_configuration['status_error_days']
  end
end
