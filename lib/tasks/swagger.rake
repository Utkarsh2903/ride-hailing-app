namespace :swagger do
  desc 'Generate Swagger documentation'
  task generate: :environment do
    require 'rswag/specs/swagger_formatter'
    
    puts "🔧 Generating Swagger documentation..."
    
    # Run rswag specs to generate swagger files
    system("RAILS_ENV=production bundle exec rake rswag:specs:swaggerize")
    
    puts "✅ Swagger documentation generated!"
    puts "📁 Location: swagger/v1/swagger.yaml"
    puts "🌐 Access at: /api-docs"
  end
end

