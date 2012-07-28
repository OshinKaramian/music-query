require "rubygems"
require "music-query"
require "test/unit"
require "json"
 
class TestQuery < Test::Unit::TestCase
 
  def test_grooveshark_query
    test_data = TestQueryHelper.new

    search = MusicQuery::Grooveshark.new("fakeapikey", JSON, UriMockObject)
    puts "Querying on: #{TestQueryHelper.grooveshark_uri("a")}"
    assert_equal(search.query("a").artist_name, test_data.song("a").artist_name, "Parameters do not match")

  end

  def test_spotify_query
    test_data = TestQueryHelper.new

    search = MusicQuery::Spotify.new(JSON, UriMockObject)
    puts "Querying on: #{TestQueryHelper.spotify_uri("a")}"
    assert_equal(search.query("a").artist_name, test_data.song("a").artist_name, "Parameters do not match")
  end
 
end

class TestQueryHelper
  attr_accessor :grooveshark_uri_map, :song_hash

  def initialize()
     @grooveshark_uri_map = Hash.new
     @song_hash = Hash.new
     generate_test_case_hash
  end

  def self.grooveshark_uri(query)
    api_key = "fakeapikey"
    return "http://tinysong.com/b/#{query}?format=json&key=#{api_key}"
  end

  def self.spotify_uri(query)
    return "http://ws.spotify.com/search/1/track.json?q=#{query}"
  end

  def grooveshark_return_json(key)
      hash = @song_hash[key]
      return %({"Url": "#{hash[:url]}",
        "SongID": #{hash[:song_id]},
        "SongName": "#{hash[:song_name]}",
        "ArtistID": #{hash[:artist_id]},
        "ArtistName": "#{hash[:artist_name]}",
        "AlbumID": #{hash[:album_id]},
        "AlbumName": "#{hash[:album_name]}"
      })
  end

  def spotify_return_json(key)
     hash = @song_hash[key]
      %({ "info": {"num_results": 2087, "limit": 100, "offset": 0, "query": "foo", "type": "track", "page": 1},
          "tracks": [{"album": {"href": "#{hash[:album_id]}", "name": "#{hash[:album_name]}" }, 
                         "name": "#{hash[:song_name]}", 
                         "href": "#{hash[:url]}", 
                         "artists": [{"href": "#{hash[:artist_id]}", "name": "#{hash[:artist_name]}"}], 
                         "track-number": "11"
                        }]
         })
  end
 
  def song(key)
    hash = @song_hash[key]
    song = MusicQuery::Song.new("", "")
    song.artist_name = hash[:artist_name]
    song.song_title = hash[:song_name]
    song.id = hash[:url]
    return song
  end

  def generate_test_case_hash
     @song_hash["a"] = { 
       :url => "girltalk.com", 
       :song_id => "1234", 
       :song_name => "Walk", 
       :artist_id => "1234", 
       :artist_name => "Girl Talk", 
       :album_id => "1234", 
       :album_name => "Girl Talk"
     } 
  end


end

class UriMockObject

    def initialize(text)
      @test = TestQueryHelper.new

      if isGroovesharkURI(text)
        parameters = text.split("/")
        query_param = parameters[4].split("?")[0]
        @query_data = @test.grooveshark_return_json(query_param)

      elsif isSpotifyURI(text)
        parameters = text.split("?q=")
        query_param = parameters[1]
        @query_data = @test.spotify_return_json(query_param)
      end

    end

    def self.parse(text)
      mock = UriMockObject.new(text)
      return mock
    end

    def read
      return @query_data
    end

    
    def isGroovesharkURI(text)
      return text.include? "tinysong.com" 
    end

    def isSpotifyURI(text)
      return text.include? "spotify.com" 
    end
   
end
