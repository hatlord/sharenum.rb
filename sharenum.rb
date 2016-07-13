#!/usr/bin/env ruby
#Shit user share finder

require 'tty-command'
require 'colorize'
require 'trollop'
require 'logger'


class Sharenum

  def initialize
    
    @users = []
    @log = Logger.new('debug.log')
    @cmd = TTY::Command.new(output: @log)

  end

  def arguments
    @@opts = Trollop::options do 
      version "sharenum 0.1b".light_blue

      opt :hosts, "Choose hosts to enumerate", :type => String
      opt :user, "Username", :type => String
      opt :pass, "Password", :type => String
      opt :combo, "Username:Password combo list", :type => String

        if ARGV.empty?
          puts "Need Help? Try ./rsdns --help or -h"
        exit
      end
    end
  end

  def findshares
    if @@opts[:user]
      hosts = File.readlines(@@opts[:hosts]).map(&:chomp &&:strip)
  
    hosts.each do |host|
      out, err = @cmd.run!("enum4linux -u #{@@opts[:user]} -p #{@@opts[:pass]} -S #{host}", timeout: 0.5)
        puts out.lines.grep(/Listing: Ok/i)
      end
    end
  end

  def combo
    if @@opts[:combo]
      hosts = File.readlines(@@opts[:hosts]).map(&:chomp &&:strip)
      combolist = File.readlines(@@opts[:combo]).map(&:chomp &&:strip)

      combolist.each do |com|
        splitter = com.split(':')
          hosts.each do |host|
            out, err = @cmd.run!("enum4linux -u #{splitter[0]} -p #{splitter[1]} -S #{host}", timeout: 0.5)
              if out =~ /Server doesn't allow session using username/
                puts "Connection failed for user #{splitter[0]} on host #{host}"
              end
              output = out.lines.grep(/Listing: Ok/i)
              output.each { |e| puts "User: #{splitter[0]} #{e}" }
        end
      end
    end
  end

end

run = Sharenum.new

run.arguments
run.findshares
run.combo