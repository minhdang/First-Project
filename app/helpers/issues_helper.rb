module IssuesHelper
  def display_pdf_inline(url, height='900')
    render :partial => 'shared/ipaper', :locals => { :url => url, :height => height }
  end
end