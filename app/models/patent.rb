class Patent < ActiveRecord::Base
  # Patent Stages
  StageIssued   = 'issued'
  StagePending  = 'filed'
  # Patent Types
  IssuedTypes   = ['design_issued', 'utility_issued']
  PendingTypes  = ['utility_application', 'provisional_application', 'design_application', 'pct_application']
  
  belongs_to :idea
  
  validates_presence_of :idea_id, :patent_type
  validates_presence_of :patent_number, :if => :issued?
  
  has_attached_file :application,
    :storage        => :s3,
    :s3_credentials => { :access_key_id => App.s3[:access_key_id], :secret_access_key => App.s3[:secret_access_key] },
    :path           => "ideas/:idea_id/patents/:basename.:extension",
    :url            => "ideas/:idea_id/patents/:basename.:extension",
    :bucket         => App.s3[:en_bucket]
    
  Paperclip.interpolates(:idea_id) { |attachment,style| attachment.instance.idea_id }
    
  def issued?
    stage == StageIssued
  end
  
  def pending?
    stage == StagePending
  end
  
  def available_types
    if issued?
      IssuedTypes.map {|t| [t.titleize,t]}
    else
      available = PendingTypes.map {|t| [t.titleize,t]}
      available.last.first.gsub! 'Pct', 'PCT' #Figure out better way
      available
    end
  end
  
end
