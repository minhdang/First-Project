class Document < ActiveRecord::Base
  
  acts_as_versioned
  acts_as_url :title
  
  has_attached_file :pdf,
                    :path => ":rails_root/public/system/documents/:document_url/:document_url-v:document_version.:extension",
                    :url  => "/system/documents/:document_url/:document_url-v:document_version.:extension"
  Paperclip.interpolates(:document_url) { |attachment,style| attachment.instance.url }
  Paperclip.interpolates(:document_version) { |attachment,style| attachment.instance.version }
  
  formats_attributes :body, :sanitize => false
  before_save :generate_pdf
  
  validates_presence_of :title, :body
  validates_uniqueness_of :title
  
  def self.innovator_agreement
    Document.find_by_url('innovator-agreement')
  end
  
  def to_param
    url
  end
  
  protected
  
    def generate_pdf
      return unless body_html
      
      prince = Prince.new
      prince.add_style_sheets(File.join(ActionView::Helpers::AssetTagHelper::STYLESHEETS_DIR, 'pdf.css'))
      
      temp_pdf = Tempfile.new("#{url}.pdf")
      temp_pdf.puts(prince.pdf_from_string(body_html))
      
      self.pdf = temp_pdf
    end
end

class Document::Version
  has_attached_file :pdf,
                    :path => ":rails_root/public/system/documents/:document_url/:document_url-v:document_version.:extension",
                    :url  => "/system/documents/:document_url/:document_url-v:document_version.:extension"
  Paperclip.interpolates(:document_url) { |attachment,style| attachment.instance.url }
  Paperclip.interpolates(:document_version) { |attachment,style| attachment.instance.version }
  
  def to_param
    version.to_s
  end
end