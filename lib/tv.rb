module TV
  require 'rubygems'
  require 'hpricot'
  require 'open-uri'
  require 'term/ansicolor'

  class Episode
    attr_accessor :season, :number, :aired, :name, :summary

    def initialize(season, number, aired, name, summary)
      @season   = season.to_i
      @number   = number.to_i
      @aired    = aired
      @name     = name
      @summary  = summary
    end
    
    def id
      ("#{season}"+ ("%02d" % number)).to_i
    end

    def <=>(other)

      if self.season != other.season
        result = (self.season <=> other.season)
      elsif self.number.nil? or other.number.nil?
        result = 0
      elsif
        result = (self.number <=> other.number)
      end

      return result
    end
    
    def to_s
      "#{@name} Season #{@season}, Episode #{@number} Aired: #{@aired}"
    end
  end

  class Show 
    attr_accessor :id, :tag, :title, :score, :episodes
    
    def initialize(tag, id, title, score, episodes) 
      @id = id
      @tag = tag
      @title = title
      @score = score
      @episodes = episodes.sort
    end

    def this_week
      d_start = Date.parse("Sunday")
      d = d_start..(d_start + 6)
      @episodes.find_all {|x| d.include?(x.aired) }
    end

    def next_week
      d_start = Date.parse("Sunday") + 7
      d = d_start..(d_start + 6)
      @episodes.find_all {|x| d.include?(x.aired)}
    end
    
    def current_season
      d = Date.today
      list = @episodes.sort_by {|x|  
        if not x.aired.nil? then
          (x.aired - d).abs
        else
          # set the return value to a really large delta to discount 
          # dates that are not set
          100000
        end
      }
      list.first.season
    end

    def get_season(number)
      @episodes.find_all {|e| e.season == number}.sort
    end
  end

  class ShowController
    
    def self.fetch_show(tag, id)
      c = Term::ANSIColor
      begin
        url = "http://www.tv.com/#{tag}/show/#{id}/episode_guide.html?season=0&tag=season_dropdown%3Bdropdown"
        hp  = Hpricot(open(url))
        title ||= $1 if (hp/"div.content_title/h2").inner_text.match(/((?:\w*'?\s*)*):/)
        score ||= $1 if (hp/"div.score").inner_text.match(/(\d\.\d)/)
        episodes = Array.new

        (hp/"div#eps_guide/div.body/ul/li").each do |li|
          t_text = (li/"div.wrap/h3.title").inner_text.split(":")
          if not t_text.empty? then
            season  = $1.to_i if t_text[0].match(/Season (\d+),/)
            episode = $1.to_i if t_text[0].match(/Ep (\d+)/)
            if t_text.length > 2 then
              name = t_text[1..(t_text.size - 1)].join(":").strip
            else
              name = t_text[1].strip if not t_text[1].nil?
            end
          else
            season, episode, name = nil
          end
          search = (li/"div.details/div.info/span.air_date")
          if not search.empty? then
            aired = Date.parse($1) if search.inner_text.match(/(\d+\/\d+\/\d\d\d\d)/)
          end
          if summary = (li/"div.details/div.info/p") then
            summary = summary.inner_text
          end
          episodes.push(Episode.new(season, episode, aired, name, summary))
        end
        Show.new(tag, id, title, score, episodes)
      rescue
        print c.red, c.bold, "Error encountered while processing show with tag: #{tag}", c.clear, "\n"
        print c.red, $!, c.clear, "\n"
      end
    end
  end
end


