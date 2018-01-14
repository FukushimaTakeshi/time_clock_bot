# require_relative '../../models/menu'

class Register
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

    messages
  end
end
