require 'rubygems'

puts "==========================================================================="
puts "  Postage plugin successfully installed"
puts "===========================================================================\n\n"
puts "  Testing required Ruby Gems:"

missing_gems = [ ]
required_gems = %w[ httparty ]

required_gems.each do |gem_name|
  found = false
  begin
    gem gem_name
    found = true
  rescue Gem::LoadError
    missing_gems << gem_name
  end
  puts "    #{gem_name} = #{found ? 'Installed' : 'Not found'}"
end

unless (missing_gems.empty?)
  puts ""
  puts "  The missing gems can usually be installed with:"
  puts "     % sudo gem install #{missing_gems * ' '}"
end

puts ""
puts "  Don't forget to add the gem dependencies to the environment.rb file:"
required_gems.each do |gem_name|
  puts "    config.gem '#{gem_name}'"
end

puts ""
puts "---------------------------------------------------------------------------"
puts ""
puts "  To finish configuring plugin please run:"
puts ""
puts "    rake postage:setup API_KEY=YOUR_API_KEY_HERE"
puts "    rake postage:test"
puts ""
puts "---------------------------------------------------------------------------"
puts ""
puts "  For more information please visit http://postageapp.com/docs"
