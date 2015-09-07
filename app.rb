def run
  require "rubygems"
  require 'nokogiri'
  require 'open-uri'

  #GET SUBTEXT INFO
  doc = Nokogiri::HTML(open("https://news.ycombinator.com"))
  rows = doc.xpath('//table/tr')
  details1 = rows.collect do |row|
    detail1 = {}
    [
      [:score, 'td[2]/span/text()'],
      [:user, 'td[2]/a[1]/text()'],
      [:time, 'td[2]/a[2]/text()'],
      [:comments, 'td[2]/a[3]/text()'],
      [:id, 'td[2]/a[3]/@href']
    ].each do |name, xpath|
      detail1[name] = row.at_xpath(xpath).to_s.strip
    end
    detail1
  end

  #CLEAN UP INFO
  subtext = Array.new
  x = -1
  details1.each do |post|
    x += 1
    if details1[x][:time] != ''
      subtext << post
    end
  end

  #GET TITLE AND LINK
  doc = Nokogiri::HTML(open("https://news.ycombinator.com"))
  rows = doc.xpath('//table/tr')
  details = rows.collect do |row|
    detail = {}
    [
      [:title, 'td[3]/a/text()'],
      [:url, 'td[3]/a/@href'],
      [:real, 'td[2]'],
      [:slug, 'td[3]/span[2][@class="sitebit comhead"]'],
    ].each do |name, xpath|
      detail[name] = row.at_xpath(xpath).to_s.strip
    end
    detail
  end

  #CLEAN UP DATA
  articles = Array.new
  x = -1
  details.each do |post|
    x += 1
    if details[x][:title] != '' && details[x][:real] != '<td></td>'
      articles << post
    end
  end

  #CREATE HTML
  x = 0
  @send = ''
  while x < 29
    @title = articles[x][:title]
      .sub('&acirc;&#128;&#152;', "'") #UTF-8 FIX
      .sub('&acirc;&#128;&#147;', '- ')
      .sub('&acirc;&#128;&#153;', "'")
      .sub('&Acirc;', '')
      .sub('&acirc;&#128;&#156;', '"')
      .sub('&acirc;&#128;&#157;', '"')
    @url = articles[x][:url]
    @score = subtext[x][:score]
    @user = subtext[x][:user]
    @user_url = "https://news.ycombinator.com/user?id=#{subtext[x][:user]}"
    @time = subtext[x][:time]
    @comments = subtext[x][:comments]
    @comments_url = "https://news.ycombinator.com/#{subtext[x][:id]}"
    @id = subtext[x][:id]
    @slug = articles[x][:slug]

    @send += "\n<li>\n          <ul>\n              <li>#{x+1}."\
          "<div class=\"votearrow\" title=\"upvote\">"\
            "</div><a href=\"#{@url}\"><span class=\"title\">#{@title}"\
            "</span></a>#{@slug}</li>\n
                <li class=\"subtext\">#{@score} by <a href=\"#{@user_url}\">"\
                "#{@user}</a> #{@time} "\
            "| <a href=\"#{@comments_url}\">#{@comments}</a></li>"\
            "\n         </ul>\n</li>\n"

   x += 1
  end
  return @send
end
