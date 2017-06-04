#!/bin/env ruby
# encoding: utf-8

class CorpseHttp

  def style

    return "
<style>
  .activity { }
  .activity ln { width:33%; min-width:200px; display:inline-block; height:25px;overflow: hidden}
  .activity .value { color:#555; margin-left:10px; font-size:14px }
  .activity .progress { max-width:50px; width:30px; float:left; margin-top:10px; margin-right:15px}
  #notice { font-family:'din_regular'; font-size:16px; line-height:26px; background:#fff; padding:15px 20px; border-radius:3px}
  #notice a { font-family: 'din_medium'}
</style>"

  end

  def view

    html = "<p>#{@term.bref}</p>#{@term.long.runes}\n"
    html += recent
    html += event
  
    return html

  end

  def event

    return "<p id='notice'>I am currently in {{$ hundredrabbits get_location}}, {{sailing|Hundred rabbits}} across the Pacific Ocean toward New Zealand. My access to internet is limited and will not be able to reply to the {{forum}} as frequently, or answer emails. I will get back to you upon landfall. You can track our sail {{here|http://100r.co/#map}}.</p>".markup

  end

  def recent

    html = ""

    @topics = {}

    count = 0
    @term.logs.each do |log|
      if count == 60 then break end
      if log.topic.to_s == "" then next end
      @topics[log.topic] = @topics[log.topic].to_i + log.value
      count += 1
    end

    h = @topics.sort_by {|_key, value| value}.reverse
    max = h.first.last.to_f

    h.each do |name,val| # <div class='progress'><div class='bar' style='width:#{(val/max)*100}%'></div></div>
      html += "<ln><a href='/#{name}'>#{name}</a><span class='value'>#{val}h</span>#{Progress.new(val,max)}<hr/></ln>"
    end

    return "#{Graph_Timeline.new(term,0,100)}<list class='activity'>#{html}</list>"

  end

end