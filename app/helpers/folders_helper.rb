module FoldersHelper
  
  def breadcrumbs(folder, breadcrumbs = '')
    breadcrumbs = "<span class=\"breadcrumb nowrap\">#{link_to(folder.name, folder)}</span><span>/</span> #{breadcrumbs}"
    breadcrumbs = breadcrumbs(folder.parent, breadcrumbs) unless folder == Folder.root
    breadcrumbs.html_safe
  end
  
  

  def document_icon(extension)
    if FileTest.exists?("#{Rails.root}/public/images/fileicons/#{extension}.png")
      "/images/fileicons/#{extension}.png"
    else
      '/images/file.png'
    end
  end
  
  def document_status(i)
		status = [
			t(:initialisation),
			t(:in_queue),
			t(:indexing),
			t(:ready)
		]
		if i 
			status[i]
		else
		  "undefined"
		end
	end
end
