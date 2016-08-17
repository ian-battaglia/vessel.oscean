# encoding: utf-8

class Log

	def initialize(date,content)

		@log = content
		@log['DATE'] = date

	end

	def time
		Date.new(year,month,day).to_time.to_i
	end

	def year
		return @log['DATE'][0,4].to_i
	end

	def month
		return @log['DATE'][5,2].to_i
	end

	def day
		return @log['DATE'][8,2].to_i
	end

	def date
		return Desamber.new(@log['DATE'])
	end

	def elapsed
		return Time.new.to_i - Date.new(year,month,day).to_time.to_i
	end

	def offset

		if year < 1 then return "" end

		timeDiff = (elapsed/86400)

		if timeDiff < -1 then return "In "+(timeDiff*-1).to_s+" days" end
		if timeDiff == -1 then return "tomorrow" end
		if timeDiff == 0 then return "today" end
		if timeDiff == 1 then return "yesterday" end
		if timeDiff == 7 then return "a week ago" end
		if timeDiff > 740 then return (timeDiff/30/12).to_s+" years ago" end
		if timeDiff > 60 then return (timeDiff/30).to_s+" months ago" end
		if timeDiff > 30 then return "a month ago" end

		return timeDiff.to_s+" days ago"
	end

	def isPassed
		if Time.new.to_i > Date.new(year,month,day).to_time.to_i then return true end
		return false
	end

	def code
		return @log['CODE'].to_s != "" ? @log['CODE'] : nil
	end

	def rune
		return code ? code[0,1] : nil
	end

	def verb
		return code ? code[2,1].to_i : 0
	end

	def value
		return code ? code[3,1].to_i : 0
	end

	def sector
		if verb.to_i == 1
			return "audio"
		elsif verb == 2
			return "visual"
		elsif verb == 3
			return "research"
		end
		return "misc"
	end

	def title
		return @log['NAME'].to_s.force_encoding("UTF-8")
	end

	def full
		return macros(@log['TEXT'].to_s.force_encoding("UTF-8"))
	end

	def task
		return @log['TASK'].to_s
	end

	def photo
		return @log['PICT'].to_i
	end

	def topic
		return @log['TERM'].to_s
	end

	def image
		if File.exist?("content/diary/"+photo.to_s+".jpg") && photo > 0
		  return "<img src='content/diary/"+photo.to_s+".jpg' class='photo'/>"
		end
		return ""
	end

	def isFeatured
		return rune == "!" ? true : nil
	end

	def isDiary
		return photo > 0 ? true : nil
	end

	def template
		html = ""
		html += "<a class='topic #{sector}' href='/#{topic}'>#{topic}</a>"
		html += "<span class='task'>#{task}</span>"
		if photo > 0
			html += "<a class='title' href='/#{topic}:diary'>#{title}</a>"
		elsif title.to_s != ""
			html += "<a class='title' href='/#{topic}:diary'>#{title}</a>"
		end
		html += "<span class='date'>#{offset}</span>"
		return "<log>"+html+"</log>"
	end

	def diary_template

		graphic = nil

		if File.exist?("/var/www/client.oscean/content/diary/#{photo}.mp4")
		  graphic = "<a href='/#{topic}' class='photo'><video autoplay loop><source src='/content/diary/#{photo}.mp4' type='video/mp4'>Your browser does not support the video tag.</video></a>"
		elsif File.exist?("/var/www/client.oscean/content/diary/#{photo}.jpg")
		  graphic = "<a href='/#{topic}' class='photo'><img src='content/diary/#{photo}.jpg'/></a>"
		end

		return "
		<content class='diary'>
			"+(graphic != nil ? graphic : "")+"
			<small><b>#{title}</b>#{date.default}</small>
			"+(full != "" ? "<div class='full'>#{full}</div>" : "")+"
		</content>"

	end

	def macros text

		search = text.scan(/(?:\{\{)([\w\W]*?)(?=\}\})/)
        search.each do |str,details|
            text = text.to_s.gsub("{{"+str+"}}",parser(str))
        end
        return text

	end

	def parser macro

		if macro.include?("diary:") then return "<img src='content/diary/#{photo}.#{macro.split(":")[1]}.jpg'/>" end
		return "{{#{macro}}}"

	end

end
