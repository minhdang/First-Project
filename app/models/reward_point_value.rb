class RewardPointValue < ActiveRecord::Base
  
  Stages = {
    1 => 250,
    2 => 500,
    3 => 750,
    4 => 1000,
    5 => 3000,
    6 => 5000,
    7 => 10000,
    8 => 50000
  }
  
  
  def self.pay_points(moves)
      moves.each do |move|
        begin
          submission = Submission.find(move.submission_id)
        rescue
          next
        end
          if submission.user.member? && submission.first
            if move.move_to < submission.stage
              puts "*******************"
              puts "Login\n"
              puts submission.user.login
              puts "Before\n"
              puts submission.user.reward_points
              submission.user.reward_points   += RewardPointValue::Stages[move.move_to]
              submission.user.lifetime_points += RewardPointValue::Stages[move.move_to]
              submission.user.save
              puts "After\n"
              puts submission.user.reward_points
              puts "*******************\n"
            elsif submission.stage == move.move_to && submission.alive?  
              puts "*******************"
              puts "Login\n"
              puts submission.user.login
              puts "Before\n"
              puts submission.user.reward_points
              submission.user.reward_points   += RewardPointValue::Stages[move.move_to]
              submission.user.lifetime_points += RewardPointValue::Stages[move.move_to]
              submission.user.save
              puts "After\n"
              puts submission.user.reward_points
              puts "*******************\n"
             else
               # do nothing
            end
          end
      end

  end
  
  
  def self.tally(submission, user, stage)
    if submission.idea.submissions_count <= 1
      user.reward_points   += RewardPointValue::Stages[stage]
      user.lifetime_points += RewardPointValue::Stages[stage]
      user.save
    end
  end
  
  def self.new_submission(submission, user)
    if user.member?
      if submission.idea.submissions_count < 1 
        user.reward_points    += RewardPointValue::Stages[1]
        user.lifetime_points  += RewardPointValue::Stages[1]
        user.save
      end
    end
  end
  
  def self.redeemable(user)
    unless user.reward_points == nil
      user.reward_points >= 50000 ? true : false
    end
  end
  
  def self.deduct_submission(user)
    if user.reward_points >= 50000
      user.reward_points =  user.reward_points - 50000
      user.save
    end
  end
  
  def self.new_member(user)
    if user.lifetime_points == nil && user.reward_points == nil
      user.reward_points = 10000
      user.lifetime_points = 10000
      user.save
    end
  end
  
end
