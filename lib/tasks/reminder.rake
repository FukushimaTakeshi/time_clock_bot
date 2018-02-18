namespace :timeclock do
  desk '勤怠登録リマインダータスク'
  task :reminder => :environment do
    webhook_controller = WebhookController.new
    webhook_controller.reminder
  end
end
