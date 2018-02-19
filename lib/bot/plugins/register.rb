require 'capybara/dsl'

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
            text: "始業時間は何時ですか？\n当てはまらない場合は4桁の数字でコメントしてね。",
            actions: [
              { type: 'postback', label: '9:00', data: '0900', displayText: '0900' },
              { type: 'postback', label: '10:00', data: '1000', displayText: '1000' },
              { type: 'postback', label: '10:30', data: '1030', displayText: '1030' },
              { type: 'postback', label: '11:00', data: '1100', displayText: '1100' }
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
            text: "就業時間は何時ですか？\n当てはまらない場合は4桁の数字でコメントしてね。",
            actions: [
              { type: 'postback', label: '17:45', data: '1745', displayText: '1745' },
              { type: 'postback', label: '19:00', data: '1900', displayText: '1900' },
              { type: 'postback', label: '19:30', data: '1930', displayText: '1930' },
              { type: 'postback', label: '20:00', data: '2000', displayText: '2000' }
            ]
          }
        }
      }
    }

  end

  NUMERICALITY_REGEX = /^[0-9０-９]{4}$/

  def parser_time(value)
    value = value.delete(':').tr('０-９', '0-9')
    return value[0, 4] if value.length == 6 && value[0, 4] =~ NUMERICALITY_REGEX
    return value if value =~ NUMERICALITY_REGEX
    false
  end

  def parser_time1(value)
    parser_time(value)
  end

  def create_message(line_event, memory)
    user = User.find_by(line_user_id: line_event['source']['userId'])
    {
      type: 'text',
      text: regist_chronus(memory, user)
    }
  end

  private

  def regist_chronus(memory, user)
    login(user)
    select_date
    register_attendance(memory)
    message = if success?
                <<~EOS
                  #{Date.today.month}/#{last_business_day} #{memory[:confirmed][:time]}～#{memory[:confirmed][:time1]} で登録しました。
                  今月の残業は#{overtime}です。

                  時間の修正はここから直接してね。
                  https://chronus-ext.tis.co.jp/Lysithea/JSP_Files/authentication/WC010_1.jsp
                EOS
              else
                "登録に失敗しました\nごめんなさい >_<;"
              end
    logout
    message
  rescue => e
    Rails.logger.error("#{e.class} (#{e.message}):\n#{e.backtrace.join("\n")}\n#{memoty}")
    "(´；ω；｀)\n登録に失敗しました\nごめんなさい >_<;"
  end

  def login(user)
    page.driver.headers = { 'User-Agent': 'Mac Safari' }
    visit('')
    find(:xpath, "//input[@class='InputTxtL'][@name='PersonCode']").set(user.user_id)
    find(:xpath, "//input[@class='InputTxtL'][@name='Password']").set(user.password)
    find(:xpath, "//*/a").click
    page.accept_alert rescue p $! # パスワード切れの考慮
  end

  def select_date
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

  def register_attendance(memory)
    # frame name="OPERATION" の操作
    page.driver.within_frame('OPERATION') do
      find(:xpath, "//*[@class='InputTxtR'][@name='StartTime']").set(memory[:confirmed][:time])
      find(:xpath, "//*[@class='InputTxtR'][@name='EndTime']").set(memory[:confirmed][:time1])

      # 計算ボタンclick
      find(:xpath, "//td[3]/a[1]/img").click

      # 別ウィンドウで開かれた実働時間を取得し、4桁にする
      handle = page.driver.browser.window_handles.last
      working_hours = page.driver.browser.within_window(handle) do
        find(:xpath, "//tr[1]/td[2]").text
      end
      working_hours.delete!(':')
      working_hours = '0' + working_hours if working_hours.length == 3

      # 元のウィンドウに実働時間を入力
      find(:xpath, "//tr[2]/td[3]/input").set(working_hours)
      find(:xpath, "//a[2]/img").click
    end
  end

  def success?
    # frame name="OPERATION" の操作
    page.driver.within_frame('OPERATION') do
      find(:xpath, "//*[@class='BdCel2'][@align='CENTER']").has_text?('△')
    end
  end

  def overtime
    # frame name="MENU" の操作
    page.driver.within_frame('MENU') do
      find(:xpath, "//table[10]//td[1]/a").click
      find(:xpath, "//table[7]//td[3]").text
    end
  end

  def logout
    page.driver.within_frame('MENU') do
      find(:xpath, "//*/table[10]//td[2]//img").click
    end
  end
end
