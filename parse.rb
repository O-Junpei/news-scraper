require 'open-uri'
require 'nokogiri'
require 'rss'
require 'json'
require 'uri'
require 'time'
require 'csv'

def parser(name)
  json_name = 'json/' + name + '.json'
  csv_name = 'csv/' + name + '.csv'
  url = 'https://news.google.com/news/rss/search/section/q/' + URI.escape(name) + '?&ned=jp&gl=JP&hl=ja'

  # Pull
  begin
    rss = RSS::Parser.parse(url)
  rescue StandardError => e
    puts 'ページの読み込み or RSS変換に失敗しますた' + e.to_s
    return
  end

  # File Check
  unless File.exist?(json_name)
    open(json_name, 'w') do |io|
      JSON.dump([], io)
    end
  end

  # Read Local Json
  contents = open(json_name) do |io|
    JSON.load(io)
  end

  # Parse RSS
  rss.channel.items.each do |item|
    date = item.pubDate.to_date
    article = {}
    article['title'] = item.title.to_s
    article['pubDate'] = date.strftime('%Y/%m/%d')
    article['link'] = item.link.to_s
    article['description'] = item.description.to_s.gsub(/<(".*?"|'.*?'|[^'"])*?>/, '')
    contents.push(article)
  end

  # Delete Duplication
  contents = contents.uniq

  # Sort
  contents = contents.sort_by {|h| h['pubDate']}.reverse

  # Save
  open(json_name, 'w') do |io|
    JSON.dump(contents, io)
  end

  # Export CSV
  CSV.open(csv_name, 'w') do |csv| # output to csv file
    contents.each do |content|
      csv << [
          content['pubDate'],
          content['title'],
          content['link'],
          content['description']]
    end
  end

end

companies = open('companies.json') do |io|
  JSON.load(io)
end

companies.each do |company|
  parser(company)
end



