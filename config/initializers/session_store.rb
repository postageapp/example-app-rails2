# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_postageapp-rails-example_session',
  :secret      => '3f7a081728fb64a73a1938a1e6f0feb99a1e9ca85787d2574e597a2ea1e7e5f09c359ca7671088ecf416d73c645a20bbd9be38c459157bd8b357ef813017e366'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
