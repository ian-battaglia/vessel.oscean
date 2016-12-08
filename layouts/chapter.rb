#!/bin/env ruby
# encoding: utf-8

class CorpseHttp

  def view
    
    @years = Desamber.new.year - 2010
    @hours = [0,0]
    @audio    = [0,0]
    @visual   = [0,0]
    @research = [0,0]
    @projects = [0,0]
    @tasks    = [0,0]
    @project_index  = {}
    @task_index  = {}
    
    generate
    
    html = "

<horaire graph>

Summary

Sectors
Hours            : #{format_val(@hours,"hours")}
Audio            : #{format_val(@audio,"hours")}
Visual           : #{format_val(@visual,"hours")}
Research         : #{format_val(@research,"hours")}

Multitasking
Projects         : #{format_val(@projects,"projects")}
Tasks            : #{format_val(@tasks,"tasks")}
Hours/Projects   : #{format_val([@hours[0]/@projects[0].to_f,(@hours[1]/@projects[1].to_f)],"hours")}
Hours/Tasks      : #{format_val([@hours[0]/@tasks[0].to_f,(@hours[1]/@tasks[1].to_f)],"hours")}
"
    
    html  += "\n"
    html  += "Projects\n"
    
    # Projects Index
    count = 0
    sum = 0
    @project_index.sort_by {|_key, value| value}.reverse.each do |project,val|
      if count > 10 then break end
      html += "#{project.append(' ',16)} : #{val.first} hours, #{val[0].to_f.percent_of(@hours[0])}%\n"
      sum += val[0]
      count += 1
    end
    if @hours[0]-sum > 0 then html += "#{"Other Projects".append(' ',16)} : #{@hours[0]-sum} hours\n" end
    
    html  += "\n"
    html  += "Tasks\n"
    
    # Tasks Index
    count = 0
    sum = 0
    @task_index.sort_by {|_key, value| value}.reverse.each do |task,val|
      if count > 10 then break end
      html += "#{task.append(' ',16)} : #{val.first} hours #{val[0].to_f.percent_of(@hours[0])}%\n"
      sum += val[0]
      count += 1
    end
    if @hours[0]-sum > 0 then html += "#{"Other Tasks".append(' ',16)} : #{@hours[0]-sum} hours\n" end

    return "<wr>#{html}</wr>"

  end
  
  def generate
    
    projects = [{},{}]
    tasks = [{},{}]
    
    Memory_Array.new("horaire",@host.path).to_a('log').each do |log|
      
      if log.year < 2010 then next end                        # Begin in 2010
        
      @hours[0] += log.year == @query.to_i ? log.value : 0    # Hours this year
      @hours[1] += log.year != @query.to_i ? log.value : 0    # Hours other years
      
      @audio[0] += log.year == @query.to_i && log.sector == :audio ? log.value : 0    # Audio hours this year
      @audio[1] += log.year != @query.to_i && log.sector == :audio ? log.value : 0    # Audio hours average
      
      @visual[0] += log.year == @query.to_i && log.sector == :visual ? log.value : 0    # Visual hours this year
      @visual[1] += log.year != @query.to_i && log.sector == :visual ? log.value : 0    # Visual hours average
      
      @research[0] += log.year == @query.to_i && log.sector == :research ? log.value : 0    # Research hours this year
      @research[1] += log.year != @query.to_i && log.sector == :research ? log.value : 0    # Research hours average
      
      if log.year == @query.to_i then projects[0][log.topic] = 1 elsif log.topic.to_s != "" then projects[1]["#{log.topic}_#{log.year}"] = 1 end
      if log.year == @query.to_i then tasks[0][log.task] = 1 elsif log.topic.to_s != "" then tasks[1]["#{log.task}_#{log.year}"] = 1 end
        
      if !@project_index[log.topic] then @project_index[log.topic] = [0,0] end
      if !@task_index[log.task] then @task_index[log.task] = [0,0] end
        
      if log.year == @query.to_i then @project_index[log.topic][0] += log.value else @project_index[log.topic][1] += log.value end
      if log.year == @query.to_i then @task_index[log.task][0] += log.value else @task_index[log.task][1] += log.value end
    end
    
    @hours[1] = @hours[1]/(@years.to_f-1)
    @audio[1] = @audio[1]/(@years.to_f-1)
    @visual[1] = @visual[1]/(@years.to_f-1)
    @research[1] = @research[1]/(@years.to_f-1)
    
    @projects = [projects.first.length,projects.last.length/(@years.to_f-1)]
    @tasks = [tasks.first.length,tasks.last.length/(@years.to_f-1)]
    
  end
  
  def format_val val,unit
  
    offset  = (100 - val.first.to_f.percent_of(val.last.to_f)) * -1
    symbol  = offset > 0 ? "+" : ""
    return "#{val.first.to_i} #{unit} #{symbol}#{offset}%"
    
  end
  
end