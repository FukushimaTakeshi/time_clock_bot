class Other

  def create_message(_line_event, memory)
    messages = {
      type: 'text',
      text: memory[:intent][:fulfillment][:speech]
    }
    messages
  end
end
