#!/usr/bin/env ruby
#Share permission enumerator - Needs enum4linux. http://github.com/hatlord/sharenum.rb

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
      opt :domcombo, "Domain:Username:Password combo list", :type => String

      if ARGV.empty?
        puts "Need Help? Try ./sharenum.rb --help or -h"
      exit
      end
    end
  end

  def findshares
    if @@opts[:user]
    hosts = File.readlines(@@opts[:hosts]).map(&:chomp &&:strip)
  
    hosts.each do |host|
      out, err = @cmd.run!("enum4linux -u #{@@opts[:user]} -p #{@@opts[:pass]} -S #{host}", timeout: 0.5)
        if out =~ /Listing: OK/
          output = out.lines.grep(/Listing: Ok/i)
          output.each { |out| puts "User: #{@@opts[:user]} #{out}"}
        else
          puts "Listing not possible on #{host} with user #{@@opts[:user]}".light_red
        end
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
              if out =~ /Listing: OK/
                output = out.lines.grep(/Listing: Ok/i)
                output.each { |out| puts "User: #{splitter[0]} #{out}"}
              else
                puts "Listing not possible on #{host} with user #{splitter[0]}".light_red
          end
        end
      end
    end
  end

  def domaincombo
    if @@opts[:domcombo]
      hosts = File.readlines(@@opts[:hosts]).map(&:chomp &&:strip)
      combolist = File.readlines(@@opts[:combo]).map(&:chomp &&:strip)

      combolist.each do |com|
        splitter = com.split(':')
          hosts.each do |host|
            out, err = @cmd.run!("enum4linux -u #{splitter[0]}/#{splitter[1]} -p #{splitter[2]} -S #{host}", timeout: 0.5)
              if out =~ /Listing: OK/
                output = out.lines.grep(/Listing: Ok/i)
                output.each { |out| puts "User: #{splitter[0]} Domain:#{splitter[1]} #{out}"}
              else
                puts "Listing not possible on #{host} with user #{splitter[0]} and domain #{splitter[1]}".light_red
          end
        end
      end
    end

  end

end

run = Sharenum.new

run.arguments
run.findshares
run.combo
run.domaincombo