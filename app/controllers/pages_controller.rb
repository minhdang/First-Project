class PagesController < ApplicationController
  
  before_filter :find_pages, :only => :show
  
  def show
  end
  
  def searches
  end
  
  def features
  end
  
  def sponsor
  end

  # temp insider preview page
  def preview
  end
  
  #static about us page
  def about
    render :layout => 'centered_page'
  end


  # Legacy Static Pages
  # Redirect to new CMS versions
  def terms_of_service
    redirect_to document_path('terms-of-service'), :status => :moved_permanently
  end
  #def about_us
   # redirect_to '/pages/about', :status => :moved_permanently
  #end
  def opportunities
    redirect_to '/pages/searches', :status => :moved_permanently
  end
  def education
    redirect_to '/pages/education', :status => :moved_permanently
  end
  def inventor_organizations
    redirect_to '/pages/education/inventor-organizations', :status => :moved_permanently
  end
  def independent_inventor_products
    redirect_to '/pages/education/independent-inventors-products', :status => :moved_permanently
  end
  def beware_of_scams
    redirect_to '/pages/education/beware-of-scams', :status => :moved_permanently
  end
  def inventing_abcs
    redirect_to '/pages/education/abcs-of-inventing', :status => :moved_permanently
  end
  def frequently_asked_questions
    redirect_to '/pages/education/frequently-asked-questions', :status => :moved_permanently
  end
  def fun_facts
    redirect_to '/pages/education/fun-facts', :status => :moved_permanently
  end
  def other_helpful_links
    redirect_to '/pages/education/other-helpful-links', :status => :moved_permanently
  end
  def patent_search
    redirect_to '/pages/education/patent-search', :status => :moved_permanently
  end
  def lps_faq
    redirect_to '/pages/live-product-searches/lps-faq', :status => :moved_permanently
  end
  def support
    redirect_to 'http://support.edisonnation.com', :status => :moved_permanently
  end
  
  
  protected

    
    def find_pages
      page_urls = params[:id].split('/')
      @pages    = [] 
      
      page_urls.each do |url|
        @pages << (@pages.any? ?
          @pages.last.children.published.find_by_url!(url) :
          Page.top.published.find_by_url!(url))
      end
      
      @page = @pages.last
    end
  
end
