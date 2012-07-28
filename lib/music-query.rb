##
# Module that contains classes that perform queries to pull song information up
# from various platforms.

module MusicQuery
  require 'open-uri'
  require 'json'
 
  ##
  # This is a base class to handle query requests 

  class MusicQuery

    ##
    # Creates a new base query class object.
    #
    # Optional arguments can be passed in to parse JSON and URI
    # information, if not the json and open-uri gems are used in its place

    def initialize(json_parser = JSON, uri_parser = URI)
      @json_parser = json_parser
      @uri_parser = uri_parser
    end


    ##
    # Returns name of current calling class.

    def class_name
      return self.class.name.split('::').last
    end

  end
 

  ##
  # Class that handles track query requests from Grooveshark 

  class Grooveshark < MusicQuery

    ##
    # Creates a new base query object to handle query request to 
    # Grooveshark.

    def initialize(api_key, json_parser = JSON, uri_parser = URI)
      @api_key = api_key
      super(json_parser, uri_parser)
    end

    ##
    # Queries the Grooveshark API 

    def query(query_content)
      query_base_uri = "http://tinysong.com/b/"
      query_content.gsub!(" ", "+")

      query_full = "#{query_base_uri}#{query_content}?format=json&key=#{@api_key}"
      track_response_json = @uri_parser.parse("#{query_full}").read
      track_hash = @json_parser.parse(track_response_json)
      return Song.new(self, track_hash) 
    end

  end

  ##
  # Class that handles track query requests from Spotify 

  class Spotify < MusicQuery 

    ##
    # Creates a new base query object to handle query request to 
    # Spotify.

    def query(query_content)
      return_uri = ""
      query_content.gsub!(" ", "+")

      track_response_json = @uri_parser.parse("http://ws.spotify.com/search/1/track.json?q=#{query_content}").read
      track_hash = @json_parser.parse(track_response_json)
  
      # Walk the hash and find the uri for the matching song
      track_hash["tracks"].each_with_index do |track, i|
        return Song.new(self, track)
      end
    end

  end

  
  ##
  # Class that represents Song objects for querying
  # music services. 

  class Song

    attr_accessor :artist_name, :song_title, :id
    
    ##
    # Creates a new song object containing the artist name,
    # song title and unique identifer for the track 

    def initialize(music_service, json_text)
      parse_song(music_service, json_text)
    end

    private
      
      ##
      # Parses a json object into a song object

      def parse_song(music_service, json_text)
        if music_service == ""
          return "" 
        end

        if music_service.class_name == "Grooveshark"
          parse_grooveshark(json_text)
        elsif music_service.class_name == "Spotify"  
          parse_spotify(json_text)
        end
      end

      def parse_grooveshark(return_text)
        @artist_name = return_text["ArtistName"].to_s
        @song_title = return_text["SongName"].to_s
        @id = return_text["Url"].to_s
      end

      def parse_spotify(return_text)
        @artist_name = return_text["artists"][0]["name"].to_s 
        @song_title = return_text["name"].to_s
        @id = return_text["href"].to_s
      end
    end
end

