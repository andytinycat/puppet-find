#!/usr/bin/env ruby

require 'yaml'
require 'puppet'
require 'facter'

# Deserializes the Puppet catalog file on a Puppet client, looks
# for the resource of a specific file, then prints the manifest file
# and line that the resource was defined on.

# Read the Puppet config
Puppet.clear
Puppet.parse_config
clientyamldir = Puppet[:clientyamldir]

# Open the catalog file
hostname = `hostname`.chomp
catalog_file = "#{clientyamldir}/catalog/#{hostname}.yaml"
lc = File.open(catalog_file)

if ARGV.length < 1
  puts "Usage: pfind <resource title> [<resource title>] ..."
  exit 1
end

things = ARGV

# Deserialize the catalog
begin
  catalog = Marshal.load(lc)
rescue TypeError
  lc.rewind
  catalog = YAML.load(lc)
rescue Exception => e
  raise
end

things.each do |thing|

  puts "====================================================================================="
  puts "Items in Puppet catalog matching '#{thing}':"
  puts "====================================================================================="
  found = false

  # Run through each resource looking for the one specified on the command line
  catalog.resource_keys.collect {|type,name|
    if catalog.resource(type,name).title == thing
      found = true
      resource = catalog.resource(type,name)
      puts "  Type:          #{resource.type}"
      # If resource.file or resource.line are nil, then they were added to the catalog by
      # a Ruby function executed by Puppet. You'll see this if you inspect a user, since they
      # are added to the catalog by the create_users.rb function called from the
      # create_users_noarch module.
      puts "  Manifest file: #{resource.file || 'inside a Ruby function'}"
      puts "  Line:          #{resource.line || 'inside a Ruby function'}"
      puts "  Manifest code:"
      resource.to_manifest.each_line {|line| puts "   #{line}"}
      puts "-------------------------------------------------------------------------------------"
    end
  }

  unless found
    puts "  Resource not found in Puppet catalog - not controlled by Puppet"
  end

end
