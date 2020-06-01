# rubocop:disable Naming/AccessorMethodName
require "shellwords"
require "open3"
require "json"

module MusicAppCli
  module Script
    module_function

    def osascript(script, *args)
      out, err, status = Open3.capture3("osascript", "-l", "JavaScript", "-e", script, *args)
      unless status.success?
        raise err
      end

      [out, err, status]
    end

    def get_metadata
      script = <<~JS
        function run(argv) {
          var itunes = Application("Music");
          var selection = itunes.browserWindows[0].selection();
          var attributes = [];

          for (var i in selection) {
            attributes.push({
              track_number: selection[i].trackNumber(),
              name: selection[i].name(),
              file_name: selection[i].location().toString(),
              comment: selection[i].comment(),
            });
          }

          return JSON.stringify(attributes);
        }
      JS

      out, _err, _status = osascript(script)
      JSON.parse(out)
    end

    def set_metadata(metadata)
      script = <<~JS
        function run(argv) {
          var itunes = Application("Music");
          var selection = itunes.browserWindows[0].selection();
          var metadata = JSON.parse(argv[0]);
          var track = null;

          for (var i in selection) {
            track = metadata[i]
            if (!track) continue;

            if (track.track_number) selection[i].trackNumber = track.track_number;
            if (track.name) selection[i].name = track.name;
            if (track.comment) selection[i].comment = track.comment;
          }
        }
      JS

      out, _err, _status = osascript(script, metadata.to_json)
      out
    end
  end
end
# rubocop:enable Naming/AccessorMethodName
