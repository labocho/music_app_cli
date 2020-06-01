require "thor"

module MusicAppCli
  class Cli < Thor
    desc "get", "Get and print metadata"
    option :fields, aliases: :f, type: :string
    def get
      fields = case options[:fields]
      when "all"
        :all
      when nil
        :default
      else
        options[:fields].split(",")
      end

      Script.get_metadata(fields).each do |track|
        puts track.to_json
      end
    end

    desc "set", "Set metadata"
    def set
      puts Script.set_metadata(JSON.parse($stdin.read))
    end
  end
end
