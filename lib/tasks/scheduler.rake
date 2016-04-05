desc "This task is called by the Heroku scheduler add-on for Lottominer"
task :update_feed => :environment do
  puts "Adding new lotto results..."
  generate_result
  puts "done."
end

def generate_result
  @result = LottoResult.create(game: "SuperLotto 6/49", numbers: "3 6 8 12 16 49", won: false)
  @result.save
end