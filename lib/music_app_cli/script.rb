# rubocop:disable Naming/AccessorMethodName
require "shellwords"
require "open3"
require "json"

module MusicAppCli
  module Script
    ITEM_PROPERTIES = %w(
      name
    )
    TRACK_PROPERTIES = %w(
      album
      albumArtist
      albumDisliked
      albumLoved
      albumRating
      albumRatingKind
      artist
      bitRate
      bookmark
      bookmarkable
      bpm
      category
      cloudStatus
      comment
      compilation
      composer
      databaseID
      dateAdded
      description
      discCount
      discNumber
      disliked
      downloaderAppleID
      downloaderName
      duration
      enabled
      episodeID
      episodeNumber
      eq
      finish
      gapless
      genre
      grouping
      kind
      longDescription
      loved
      lyrics
      mediaKind
      modificationDate
      movement
      movementCount
      movementNumber
      playedCount
      playedDate
      purchaserAppleID
      purchaserName
      rating
      ratingKind
      releaseDate
      sampleRate
      seasonNumber
      shufflable
      skippedCount
      skippedDate
      show
      sortAlbum
      sortArtist
      sortAlbumArtist
      sortName
      sortComposer
      sortShow
      size
      start
      time
      trackCount
      trackNumber
      unplayed
      volumeAdjustment
      work
      year
    )
    FILE_TRACK_PROPERTIES = %w(
      location
    )
    FULL_PROPERTIES = ITEM_PROPERTIES + TRACK_PROPERTIES + FILE_TRACK_PROPERTIES
    DEFAULT_PROPERTIES = %w(album albumArtist artist discCount discNumber name trackCount trackNumber location)

    module_function

    def osascript(script, *args)
      out, err, status = Open3.capture3("osascript", "-l", "JavaScript", "-e", script, *args)
      unless status.success?
        raise err
      end

      [out, err, status]
    end

    def get_metadata(properties)
      properties = case properties
      when :all
        FULL_PROPERTIES
      when nil
        DEFAULT_PROPERTIES
      else
        invalid = properties - FULL_PROPERTIES
        unless invalid.empty?
          raise "Unknown properties: #{invalid.inspect}"
        end
        properties
      end

      script = <<~JS
        function run(argv) {
          var itunes = Application("Music");
          var selection = itunes.browserWindows[0].selection();
          var trackProperties = JSON.parse(argv[0]);
          var tracks = [];

          for (var i in selection) {
            var props = {};
            var track = selection[i];

            for (var j in trackProperties) {
              var prop = trackProperties[j];
              switch(prop) {
                case "location":
                  if (track.class() != "fileTrack") continue;
                  props.location = track.location().toString();
                  break;
                default:
                  props[prop] = track[prop]();
              }
            }

            tracks.push(props);
          }

          return JSON.stringify(tracks);
        }
      JS

      out, _err, _status = osascript(script, properties.to_json)
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
