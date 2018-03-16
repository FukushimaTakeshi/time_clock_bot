require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do

  describe 'GET / #home' do
    before { get root_path }
    it 'httpステータスコード200を返すこと' do
      expect(response).to have_http_status(200)
    end
    it 'home画面が表示されること' do
      expect(response.body).to include('あなたの代わりにくろのす登録するよ')
    end
  end
end
