module ApplicationHelper
    def icon(name)
        "<i class='icon-#{name}'></i> ".html_safe
    end
    
    def document_icon(extension)
        if FileTest.exists?("#{Rails.root}/public/images/fileicons/#{extension}.png")
          icon("file-#{extension}")
        else
          icon("file")
        end
    end

  def breadcrumbs(fileorfolder, active=true)
    if fileorfolder.is_a? Folder
        parent = fileorfolder.parent 
        name = fileorfolder.name 
        icon = icon('folder-open')
    elsif fileorfolder.is_a? Document
        parent = fileorfolder.folder 
        name = fileorfolder.name 
        icon = document_icon(fileorfolder.attachment_file_type)
    elsif fileorfolder.is_a? Scan
        parent = fileorfolder.folder.parent
        name = fileorfolder.folder.name 
        icon = icon('tasks')
    elsif fileorfolder.is_a? Domain
        parent = fileorfolder.folder.parent
        name = fileorfolder.folder.name 
        icon = icon('globe')
    end
    rec_breadcrumbs(parent, "<li class='#{'active' if active}'>#{icon+name}</li>").html_safe
  end

  def rec_breadcrumbs(folder, breadcrumbs = '')
    icon = icon('folder-open')
    breadcrumbs = "<li>#{link_to(icon+folder.name, folder)} <span class='divider'>/</span></li> #{breadcrumbs}"
    breadcrumbs = rec_breadcrumbs(folder.parent, breadcrumbs) unless folder == Folder.root
    breadcrumbs.html_safe
  end
end
