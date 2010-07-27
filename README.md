Ruby on Rails 2 Example Application for PostageApp
==================================================

A quick example on how to integrate [PostageApp](http://postageapp.com) email delivery with Ruby on Rails 2 application using [PostageApp Gem](http://github.com/theworkinggroup/postageapp-gem)


Configuration
-------------

1. Sign up with [PostageApp](http://postageapp.com)
2. Create a Project (optionally attach it to a mail server)
3. Copy API key into /config/initializers/postageapp.rb
        
        PostageApp.configure do |config|
          config.api_key = 'PROJECT_API_KEY'
        end

4. Start the application