namespace :timeclock do
  desc '勤怠登録リマインダータスク'
  task :reminder => :environment do
    webhook_controller = WebhookController.new
    webhook_controller.reminder
  end
end
