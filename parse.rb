require 'open-uri'
require 'nokogiri'
require 'rss'
require 'json'
require 'uri'
require 'time'

def parser(name)
  file_name = name + '.json'
  url = 'https://news.google.com/news/rss/search/section/q/' + URI.escape(name) + '?&ned=jp&gl=JP&hl=ja'
  # Pull
  begin
    rss = RSS::Parser.parse(url)
  rescue StandardError => e
    puts 'ページの読み込み or RSS変換に失敗しますた' + e.to_s
    return
  end

  # File Check
  unless File.exist?(file_name)
    open(name + '.json', 'w') do |io|
      JSON.dump([], io)
    end
  end

  # Read Local Json
  contents = open(file_name) do |io|
    JSON.load(io)
  end

  # Parse RSS
  rss.channel.items.each do |item|
    date = item.pubDate.to_date
    article = {}
    article['title'] = item.title.to_s
    article['pubDate'] = date.strftime('%Y/%m/%d')
    article['link'] = item.link.to_s
    contents.push(article)
  end

  # Delete Duplication
  new_contents = []
  (0..contents.size - 1).each do |i|
    is_contain = false
    (0..new_contents.size - 1).each do |j|
      is_contain = true if contents[i]['title'].eql? new_contents[j]['title']
    end
    new_contents.push(contents[i]) unless is_contain
  end

  contents = contents.uniq

  # Sort
  new_contents = new_contents.sort_by { |h| h['pubDate'] }.reverse
  new_contents = contents.uniq.sort_by { |h| h['pubDate'] }.reverse

  # Save
  open(file_name, 'w') do |io|
    JSON.dump(new_contents, io)
  end

  # Export CSV

end

parser('三井物産')


