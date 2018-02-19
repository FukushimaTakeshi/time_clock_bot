Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, { timeout: 120, js_errors: false })
end

Capybara.run_server = false
Capybara.current_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
Capybara.app_host = 'https://chronus-ext.tis.co.jp/Lysithea/JSP_Files/authentication/WC010_1.jsp'
Capybara.default_max_wait_time = 5
