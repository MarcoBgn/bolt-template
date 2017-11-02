# frozen_string_literal: true

if Rails.env.test? || Rails.env.development?
  namespace :documentation do

    desc 'Generate the API documentation'
    task generate: :environment do
      puts 'Generating v1 documentation using aglio'
      `cd doc/api-v1 && aglio --theme-template triple --theme-variables streak --theme-style default --theme-style theme.less -i index.apib -o index.html > /dev/null 2>&1`
    end
  end
end
