# require_relative '../../models/menu'

class UserRegistration
  attr_reader :required_slot

  def initialize
    @required_slot = {
      number: {
        line_reply_message: {
          type: 'text',
          text: 'CHRONUSのユーザIDを教えて下さい。%0D%0A 例:1234567 %0D%0A ※数字のみ'
        }
      },
      any: {
        line_reply_message: {
          type: 'text',
          text: 'パスワードを教えて下さい。',
        }
      }
    }
  end

  def parser_number(value)
    id = value.delete('^0-9')
    if id.to_i.positive?
      id
    else
      false
    end
  end

  def parser_any(value)
    if value.present?
      value
    else
      false
    end
  end

  def create_message(memory)
    messages = {
      type: 'text',
      text: 'ID/PW 登録'
    }
    messages
  end
end
