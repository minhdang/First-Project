class Statistic < ActiveRecord::Base
  
  before_create :collect_data
  
  validates_uniqueness_of :taken_at, :scope => :name
  
  def self.generate(name, start_date, end_date)
    collected = Statistic.find(:all, :select => 'name,data,taken_at',
      :conditions => ["name = ? AND taken_at BETWEEN ? AND ?", name, start_date.beginning_of_day.utc, end_date.end_of_day.utc])
    collected = collected.group_by {|s| s.taken_at.to_date}
    
    (start_date.to_date..end_date.to_date).map {|date| (collected[date] && collected[date].first) || Statistic.find_or_generate(name,date.to_time.utc)}
  end
  
  def self.find_or_generate(name,date)
    return  date == Date.today ?
            ((current = Statistic.new(:name => name, :taken_at => date)) && current.collect_data && current) :
            Statistic.find_or_create_by_name_and_taken_at(name,date)
  end

  
  def collect_data
    self.data = case name
                when 'total_users'
                  User.active_on(taken_at).count
                when 'daily_users'
                  User.change_in_users(taken_at,taken_at-1.day)
                when 'total_paid_memberships'
                  Membership.paid.active_on(taken_at).count
                when 'daily_paid_memberships'
                  Membership.change_in_members(taken_at,taken_at-1.day)
                when 'total_submissions'
                  Submission.complete.completed_by(taken_at).count
                when 'total_daily_submissions'
                  Submission.complete.completed_on(taken_at).count
                when 'total_new_submissions'
                  Submission.original.complete.completed_by(taken_at).count
                when 'daily_new_submissions'
                  Submission.original.complete.completed_on(taken_at).count
                when 'total_opt_in_submissions'
                  Submission.original(false).complete.completed_by(taken_at).count
                when 'daily_opt_in_submissions'
                  Submission.original(false).complete.completed_on(taken_at).count
                when 'total_gold_conversion_rate'
                  Membership.active_on(taken_at).count.to_f / User.active_on(taken_at).count * 100
                when 'daily_gold_conversion_rate'
                  Membership.change_in_members(taken_at, taken_at-1.day).to_f / (User.change_in_users(taken_at, taken_at-1.day)+1) * 100
                when 'annual_member_growth'
                  (Membership.active_on(taken_at).count / (Membership.active_on(taken_at-1.year).count + 1).to_f) * 100
                when 'total_searches_launched'
                  LiveProductSearch.launched_by(taken_at).count
                when 'daily_searches_launched'
                  LiveProductSearch.launched_on(taken_at)
                end
  end
  
end
