module Bot
  class Follow
    def initialize(line_user_id)
      @line_user_id = line_user_id
    end

    def create
      User.create(line_user_id: @line_user_id)
    end
  end
end
