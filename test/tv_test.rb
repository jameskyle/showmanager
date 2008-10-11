require 'rubygems'
require 'test/unit'
require './lib/tv.rb'

class ShowTest < Test::Unit::TestCase
  include TV

  def setup
    @show = Show.new('http://www.tv.com/dexter/show/62683/episode_guide.html?season=0&tag=season_dropdown%3Bdropdown')

  end
  
  def test_title
    assert_equal("Dexter", @show.title)
  end
  
  def test_score
    assert_equal("9.1", @show.score)
  end
  
  def test_episodes
    assert_equal("Dexter", @show.episodes.first.name) 
    assert_equal("Do You Take Dexter Morgan?", @show.episodes.last.name)
    assert_equal(Date.parse("12/14/2008"), @show.episodes.last.aired)
    assert_equal(Date.parse("10/1/2006"), @show.episodes.first.aired)
    assert_equal("1", @show.episodes.first.season)
    assert_equal("3", @show.episodes.last.season)
  end
end
