# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_postageapp-rails2-example_session',
  :secret      => 'e48c4b765d971eda6b367a8cb62da78dcc6e1d6bc21e7aca8dda2794019d1b50a23e4123a51b3f6dd64c64f91274c8cfdc7017b11589ee2a0dd6d38b045ee469'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
