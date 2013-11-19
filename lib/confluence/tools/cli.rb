#require 'confluence/tools'
require 'thor'
require "keychain"
require 'io/console'

module Confluence
  module Tools
    KEYCHAIN_SERVICE_NAME = 'confluence-tools'
    class CLI < Thor
      desc "account USERNAME", "add account"
      def account(user)
        print "Password for #{user}: "
        password = STDIN.noecho(&:gets).chomp
        puts

        key = fetch_key(user)
        if key
          key.password = password
          key.save!
        else
          key = Keychain.generic_passwords.create(
            service: KEYCHAIN_SERVICE_NAME, 
            password: password, 
            account: user)
        end

        puts "Saved."
      end

      desc "sync", "sync"
      option :user, type: :string, required: true
      def sync
        user = options[:user]
        key = fetch_key(user)
        unless key
          STDERR.puts "A password for #{user} is not set. You can set by `cube-automator account USERNAME`"
          abort
        end
        p key
      end

      private
      def fetch_key(user)
        Keychain.generic_passwords.where(
          service: KEYCHAIN_SERVICE_NAME,
          account: user).first
      end
    end
  end
end

