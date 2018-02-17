class Cancel
  def create_message(_line_event, memory)
    messages = [
      '',
      '',
      '',
      ''
    ]
    {
      type: 'text',
      text: messages.sample
    }
  end
end
