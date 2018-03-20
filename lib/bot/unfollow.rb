module Bot
  class Unfollow
    def initialize(line_user_id)
      @line_user_id = line_user_id
    end

    def delete
      user = User.find_by(line_user_id: @line_user_id)
      user.destroy
    end
  end
end
