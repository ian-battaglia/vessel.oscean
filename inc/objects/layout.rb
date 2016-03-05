#!/bin/env ruby
# encoding: utf-8

class Layout

  def initialize page

    @page = page

  end

  # -----------------
  # Header
  # -----------------

  def layoutHeader

    html = ""
    html += layoutHeaderLogo
    html += layoutHeaderPhoto
    html += layoutHeaderTitle

    return "<content class='header'>"+html+"</content>"

  end

  def layoutHeaderLogo

    html = ""
    html += "<a href='/'>"+Icon.new().logo(0.30)+"</a>"
    return "<content class='logo'>"+html+"</content>"

  end

  def layoutHeaderPhoto
  
    if !@page.diary then return "" end
    return "<content id='photo' class='photo' style='background-image:url(/content/diary/#{@page.diary.photo}.jpg)'></content>"

  end

  def layoutHeaderTitle

    html = "<div class='search'><div class='sector #{@page.sector}'></div><input placeholder='"+@page.title+"' id='query'/></div>"
    html += (@page.module != "" || @page.isDiary) ? "<a class='module' href='/#{@page.term.topic}'>#{Icon.new.return}Return to #{@page.term.topic}</a>" : ""
    html += (@page.module != "diary" && @page.diaries.length > 1 && @page.term.topic != "Home") ? "<a class='module' href='/#{@page.term.topic}:Diary'>#{Icon.new.diary}#{@page.diaries.length} Diaries</a>" : ""
    html += (@page.module != "horaire" && @page.logs.length > 1 && @page.term.topic != "Home") ? "<a class='module' href='/#{@page.term.topic}:Horaire'>#{Icon.new.horaire}#{@page.logs.length} Logs</a>" : ""
    html += (@page.module != "issues" && @page.issues.length > 1 && @page.term.topic != "Home") ? "<a class='module' href='/#{@page.term.topic}:Issues'>#{Icon.new.issues}#{@page.issues.length} Versions</a>" : ""

    html += (@page.term.topic == "Home") ? "<a class='module' href='/Diary'>#{Icon.new.diary}#{@page.diaries.length} Diaries</a>" : ""
    html += (@page.term.topic == "Home") ? "<a class='module' href='/Horaire'>#{Icon.new.horaire}#{@page.logs.length} Logs</a>" : ""
    html += (@page.term.topic == "Home") ? "<a class='module' href='/Issues'>#{Icon.new.issues}#{@page.issues.length} Versions</a>" : ""

    return "<content class='title'>"+html+"</content>"

  end

  def layoutHeaderSource

    if !@page.diary then return "" end
    return "<content class='source'>#{Icon.new.photo} \"<a href='/#{@page.diary.photo}'>#{@page.diary.title}</a>\" #{@page.diary.offset}.</content>"

  end

  def layoutBody

    return "<content class='body'>#{@page.view} #{layoutLinks}</content>"

  end

  def layoutLinks

    if !@page.links then return "" end

    html = ""
    @page.links.each do |linkString,v| 
      link = Link.new(linkString)
      if link.type == "quote" then next end
      html += link.template
    end
    return "<content class='storage'>"+html+"</content>"

  end

  # -----------------
  # Footer
  # -----------------

  def layoutPortal

    return "<content class='portal'>#{layoutPortalIcon}#{layoutPortalTree}</content>"

  end

  def layoutPortalIcon

    if File.exist?("content/badges/#{@page.term.topic.downcase.gsub(' ','.')}.png")
		return "<a href='/#{@page.portal.topic}' class='badge'><img src='content/badges/#{@page.term.topic.downcase.gsub(' ','.')}.png'/></a>"
    elsif File.exist?("content/badges/#{@page.portal.topic.downcase.gsub(' ','.')}.png")
		return "<a href='/#{@page.portal.topic}' class='badge'><img src='content/badges/#{@page.portal.topic.downcase.gsub(' ','.')}.png'/></a>"
    else 
		return "<a href='#{@page.term.parent}' class='badge'><img src='content/badges/oscean.png'/></a>"
    end

  end

  def layoutPortalTree

  	html = "<ul>"
    html += (@page.portal.topic != @page.term.topic) ? "<li class='head'><a href='/#{@page.portal.topic}'>#{@page.portal.topic} Portal</a></li>" : "<li class='head'><b>#{@page.portal.topic}</b></li>"
	html += "</ul>"

	html += "<ul class='siblings'>"
    @page.lexicon.siblings(@page.term).each do |term|
    	if term.topic == "Home" then next end
    	if term.topic == @page.portal.topic then next end
    	html += (term.topic != @page.term.topic) ? "<li><a href='/#{term.topic}'>#{term.topic}</a></li>" : "<li><b>#{term.topic}</b></li>"
    end
    html += "</ul>"

    if @page.term.topic != @page.portal.topic
		html += "<ul class='children'>"
    	@page.lexicon.children(@page.term).each do |term|
	    	if term.topic == "Home" then next end
	    	if term.topic == @page.term.topic then next end
	    	html += (term.topic != @page.term.topic) ? "<li><a href='/#{term.topic}'>#{term.topic}</a></li>" : "<li><b>#{term.topic}</b></li>"
	    end
	    html += "</ul>"
	end
    
    html += "</ul>"

    return html

  end

  def layoutFooter

    return "
    <content class='footer'>
    	<content>
        <dl class='icons'>
          <a href='/Oscean' class='icon'><img src='/img/interface/icon.oscean.png'/></a>
          <a href='https://github.com/neauoire' class='icon' target='_blank'><img src='img/interface/icon.github.png'/></a>
          <a href='https://twitter.com/neauoire' class='icon' target='_blank'><img src='img/interface/icon.twitter.png'/></a>
        </dl>
        <dl class='main'>
          <dd><a href='/About'><b>Devine Lu Linvega</b></a> © 2009-#{Time.now.year} <a href='http://creativecommons.org/licenses/by-nc-sa/4.0/' target='_blank' style='color:#aaa'>BY-NC-SA 4.0</a></dd>
          <dd>Currently indexing #{@page.lexicon.length} projects, built over #{@page.horaire.length} days.</dd>
          <dd class='small'><a href='/Diary'>Diary</a> &bull; <a href='/Horaire'>Horaire</a> &bull; <a href='/Issues'>Issues</a> &bull; <a href='/Desamber' class='date'>"+Desamber.new().default+"</a><br /><a href='Clock'>"+Clock.new().default+"</a> "+((Time.new - $timeStart) * 1000).to_i.to_s+"ms</dd>
        </dl>
        </content>
        <hr />
    </content>"

  end

  #----------------
  # Layout View
  #----------------

  def view

    html = ""
    html += layoutHeader
    html += "<content class='main'>"
    html += layoutHeaderSource
    html += layoutBody
    html += layoutPortal
    html += "</content>"
    html += layoutFooter
    html += "<hr />"
    return "<content>#{html}</content>"

  end

  def title

    return "XXIIVV ∴ "+@page.title
    
  end

end