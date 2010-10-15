class Admin::StatisticsController < Admin::AdminController
  
  def index
    @types = params[:data].split('+')
    @start = params[:start] || 6.months.ago.to_date
    @end   = params[:end]   || Date.today
    
    @data = @types.map {|t| Statistic.generate(t, @start, @end)}
    @series = @start..@end
  end
  
end