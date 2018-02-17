class Other
  def create_message(_line_event, memory)
    {
      type: 'text',
      text: memory[:intent][:fulfillment][:speech]
    }
  end
end
