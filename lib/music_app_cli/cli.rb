require "thor"

module MusicAppCli
  class Cli < Thor
    desc "get", "Get and print metadata"
    def get
      Script.get_metadata.each do |track|
        puts track.to_json
      end
    end

    desc "set", "Set metadata"
    def set
      puts Script.set_metadata(JSON.parse($stdin.read))
    end
  end
end
