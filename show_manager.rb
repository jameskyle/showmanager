#!/usr/bin/ruby 

require 'lib/tv'
require "yaml"
require 'optparse'
require 'ostruct'
require 'term/ansicolor'
require 'icalendar' 
require 'date'

include Icalendar
include TV

$c = Term::ANSIColor

options = OpenStruct.new
options.help = false
options.cache = true

@opts = OptionParser.new do |opts|
  opts.banner = "Description: Fetch Episode information from tv.com or from a "
  opts.banner << "previous cache"

  opts.separator "Options: "
  opts.on("-h", "--help", "Display this help/usage message") {puts opts;exit;}

  opts.on("-c", "--[no-]cache", "Use the yaml cache from previous fetch operation. Default: True") do |c|
     options.cache = c
  end
end.parse!


@shows = Array.new

if not options.cache then
  print $c.green, "Fetching information from tv.com. . . ", $c.clear, "\n" 
  show_list = YAML.load_file("config/shows.yml")
  
  show_list.each do |k,v|
    @shows.push(ShowController.fetch_show(k, v))
    system("sleep 2")
  end
  
  print $c.green, "Saving information to cache/shows.yml. . . ", $c.clear, "\n"
  File.open('cache/shows.yml', 'w') do |out|
    YAML.dump(@shows, out)
  end
else
  @shows = YAML.load_file("cache/shows.yml")
end


cal = Calendar.new

@shows.each do |show|
  current = show.get_season(show.current_season)
  current.each do |episode|
    event = Event.new
    if not episode.aired.nil?
      event.dtstart = episode.aired 
      summary = show.title + "("+ episode.id.to_s + "): " + episode.name
      event.summary = summary
      cal.add_event(event)
    end
  end
end
    #
cal_string = cal.to_ical
puts cal_string
