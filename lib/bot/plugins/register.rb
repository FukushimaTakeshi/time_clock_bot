# require_relative '../../models/menu'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'holiday_jp'

# Capybara.configure do |config|
#   config.run_server = false
#   config.current_driver = :poltergeist
#   config.javascript_driver = :poltergeist
#   config.app_host = 'https://chronus-ext.tis.co.jp/Lysithea/JSP_Files/authentication/WC010_1.jsp'
#   config.default_wait_time = 5
# end
#
# Capybara.register_driver :poltergeist do |app|
#   Capybara::Poltergeist::Driver.new(app, { timeout: 120, js_errors: false })
# end

class Register
  include Capybara::DSL
  attr_reader :required_slot

  def initialize
    @required_slot = {
      time: {
        line_reply_message: {
          type: 'template',
          altText: '始業時間は何時ですか？',
          template: {
            type: 'buttons',
            text: '始業時間は何時ですか？ 当てはまらない場合は直接コメントして下さい。',
            actions: [
              {type: 'postback', label: '9:00', data: '9:00:00'},
              {type: 'postback', label: '10:00', data: '10:00:00'},
              {type: 'postback', label: '11:00', data: '11:00:00'}
            ]
          }
        }
      },
      time1: {
        line_reply_message: {
          type: 'template',
          altText: '就業時間は何時ですか？',
          template: {
            type: 'buttons',
            text: '就業時間は何時ですか？ 当てはまらない場合は直接コメントして下さい。',
            actions: [
              {type: 'postback', label: '17:45', data: '17:45:00'},
              {type: 'postback', label: '19:00', data: '19:00:00'},
              {type: 'postback', label: '19:30', data: '19:30:00'},
              {type: 'postback', label: '20:00', data: '20:00:00'}
            ]
          }
        }
      }
    }

  end

  def parser_time(value)
    case value
    when '9:00:00', '10:00:00', '11:00:00'
      value
    else
      false
    end
  end

  def parser_time1(value)
    case value
    when '17:45:00', '19:00:00', '19:30:00', '20:00:00'
      value
    else
      false
    end
  end

  def create_message(memory)
    messages = {
      type: 'text',
      text: 'test message'
    }
    # User.find_by(id: memory[:])
    
    messages[:text] = regist_chronus(memory)
    messages
  end

  def regist_chronus(memory)
    p '----regist chronus-----'
    login
    select_date
    register_attendance
    message = if success?
                '登録しました'
              else
                '失敗しました >_<;'
              end
    logout
    message
  end

  def login
    page.driver.headers = { 'User-Agent': 'Mac Safari' }
    visit('')
    select('100：TIS株式会社', from: 'CompanyID')
    find(:xpath, "//input[@class='InputTxtL'][@name='PersonCode']").set(id)
    find(:xpath, "//input[@class='InputTxtL'][@name='Password']").set(password)
    find(:xpath, "//*/a").click
  end

  def select_date
    page.accept_alert
    # frame name="MENU" の操作
    page.driver.within_frame('MENU') do
      # カレンダーから前営業日をクリック
      find(:xpath, "//*[@id='side00']//tbody//table[2]").all('a').each do |link|
        link.click if link.text == last_business_day
      end
    end
  end

  def last_business_day(today = Date.today - 1 )
    if today.wday == 6 # Sat.
      today -= 1
    elsif today.wday == 0 # Sun.
      today -= 2
    elsif HolidayJp.holiday?(today) # public holiday
      today -= 1
    else
      return today.day.to_s
    end
    last_business_day(today)
  end

  def register_attendance
    page.driver.within_frame('OPERATION') do
      if start_time && end_time
        find(:xpath, "//*[@class='InputTxtR'][@name='StartTime']").set(start_time)
        find(:xpath, "//*[@class='InputTxtR'][@name='EndTime']").set(end_time)
      end
      find(:xpath, "//a[2]/img").click
    end
  end

  def success?
    page.driver.within_frame('OPERATION') do
      find(:xpath, "//*[@class='BdCel2'][@align='CENTER']").has_text?('△')
    end
  end

  def logout
    page.driver.within_frame('MENU') do
      find(:xpath, "//*/table[10]//td[2]//img").click
    end
  end
end
