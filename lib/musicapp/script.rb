# rubocop:disable Naming/AccessorMethodName
require "shellwords"
require "open3"
require "json"

module Musicapp
  module Script
    ITEM_PROPERTIES = %w(
      name
    ).map(&:freeze).freeze
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
    ).map(&:freeze).freeze
    FILE_TRACK_PROPERTIES = %w(
      location
    ).map(&:freeze).freeze
    FULL_PROPERTIES = (ITEM_PROPERTIES + TRACK_PROPERTIES + FILE_TRACK_PROPERTIES).freeze
    DEFAULT_PROPERTIES = %w(album albumArtist artist discCount discNumber name trackCount trackNumber location).map(&:freeze).freeze
    READONLY_PROPERTIES = %w(
      albumRatingKind
      bitRate
      cloudStatus
      databaseID
      dateAdded
      downloaderAppleID
      downloaderName
      duration
      kind
      modificationDate
      purchaserAppleID
      purchaserName
      ratingKind
      releaseDate
      sampleRate
      size
      time
    ).map(&:freeze).freeze
    WRITABLE_PROPERTIES = (FULL_PROPERTIES - READONLY_PROPERTIES).freeze

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

            for (var j in track) {
              var prop = track[j];
              selection[i][j] = prop;
            }
          }
        }
      JS

      invalid = metadata.flat_map do |track|
        track.keys - WRITABLE_PROPERTIES
      end

      unless invalid.empty?
        raise "Unknown or readonly properties: #{invalid.inspect}"
      end

      out, _err, _status = osascript(script, metadata.to_json)
      out
    end

    def play
      script = <<~JS
        function run(argv) {
          var itunes = Application("Music");
          itunes.play();
        }
      JS

      out, _err, _status = osascript(script)
      out
    end

    def pause
      script = <<~JS
        function run(argv) {
          var itunes = Application("Music");
          itunes.pause();
        }
      JS

      out, _err, _status = osascript(script)
      out
    end

    def next_track
      script = <<~JS
        function run(argv) {
          var itunes = Application("Music");
          itunes.nextTrack();
        }
      JS

      out, _err, _status = osascript(script)
      out
    end
  end
end
# rubocop:enable Naming/AccessorMethodName
