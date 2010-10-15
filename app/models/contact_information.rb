class ContactInformation < ActiveRecord::Base

  belongs_to :contactable, :polymorphic => true
  
  validates_presence_of :first_name, :last_name, :unless => :name_not_required?
  validates_presence_of :address_1, :city, :state, :country, :postal_code, :unless => :address_not_required?
  validates_presence_of :phone, :if => :phone_required?
  validates_presence_of :email, :if => :email_required?
  
  # The attributes that active merchant expects
  # to send as a billing address
  def attributes_for_active_merchant
    {
      :first_name => first_name,
      :last_name  => last_name,
      :address1   => address_1,
      :address2   => address_2,
      :city       => city,
      :state      => state,
      :country    => country,
      :zip        => postal_code
    }
  end
  
  # The full name
  def name
    "#{prefix_name} #{first_name} #{middle_name} #{last_name} #{suffix_name}".squish
  end
  
  def address
    address = address_1
    address << "\n#{address_2}" unless address_2.blank?
    address
  end
  
  def full_address
    full_address =  (address || '')
    full_address << "\n"+"#{city}, #{state} #{postal_code}".squish
    full_address << "\n#{App.countries[country.to_sym] || country}" if country
    full_address
  end
  
  # Humanized version of Contact Info
  def to_address
    s = <<-RUBY_CONTACT
          #{name}
          #{address}
          #{city}, #{state} #{postal_code}
          #{country}
        RUBY_CONTACT
    s << "#{phone}\n" if phone
    s << "#{email}\n" if email
    s << "#{website}\n" if website
    s
  end
  
  def self.from_state(states)
    inventors = []
    states.each do |st|
      inventors << ContactInformation.find(:all, :conditions => ['state = ?',st], :group => 'last_name')
    end
    inventors.flatten!
    inventors.uniq!
    inventors.each do |inventor|
      if inventor.first_name == nil && inventor.last_name == nil
        inventor.delete
      end
    end
    inventors
  end
  
  def self.from_state_csv(list)
    csv_file =File.join(Rails.root,"tmp","states.csv")
    csv = []
    File.open(csv_file, "w+") do |f|
      f << 'Last Name, First Name, State'
      f << "\n"
      list.each do |l|
        f << self.to_csv(l)
      end
    end
    
  end
  
  def self.to_csv(data)
    csv = []
    csv << "#{data.last_name}, #{data.first_name}, #{data.state}, "
    csv << "\n" 
   # csv.map{|entry| entry.to_s.strip.gsub(',','') }.join(',')
  end
  
  protected
  
    def name_not_required?
      contactable_type == 'User' || contactable_type == 'Contributor'
    end
    
    def address_not_required?
      contactable_type == 'User' || contactable_type == 'Contributor'
    end
    
    def phone_required?
      contactable_type == 'Submission'
    end
    
    def email_required?
      contactable_type == 'Submission'
    end
  
end
