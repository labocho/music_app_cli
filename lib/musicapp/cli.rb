require "thor"

module Musicapp
  class Cli < Thor
    desc "get", "Get and print metadata"
    option :field, aliases: :f, type: :string
    def get
      fields = case options[:field]
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
      new_metadata = $stdin.read.each_line.map {|l| JSON.parse(l) }
      properties = new_metadata.flat_map(&:keys).uniq.sort
      current_metadata = Script.get_metadata(properties | %w(name))

      current_metadata.zip(new_metadata).each do |(current_value, new_value)|
        puts current_value["name"]
        new_value.each do |k, v|
          puts "  #{k}:"
          puts "     #{current_value[k]}"
          puts "  -> #{v}"
        end
      end

      print "Rename?: "
      exit 1 unless $stdin.gets.chomp =~ /^y(es)?/i

      Script.set_metadata(new_metadata)
      puts "Complete!"
    end

    desc "play", "Play"
    def play
      Script.play
    end

    desc "pause", "Pause"
    def pause
      Script.pause
    end

    desc "next", "Advance to the next track"
    def next
      Script.next_track
    end
  end
end
