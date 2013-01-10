# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

#Group.create([{ :name => 'KU Admins' }, { :name => 'KU Students' }, { :name => 'CU Admins' }, { :name => 'CU Students' }])

#Group.all.each do |group|
#  Folder.all.each do |folder|
#    GroupFolderPermission.create! do |p|
#      p.group = group
#      p.folder = folder
#      p.can_create = false
#      p.can_read = folder.is_root? # New groups can read the root folder
#      p.can_update = false
#      p.can_delete = false
#    end
#  end
#end


=begin
def create_document_from_folder(path, folder)
  import_files = Dir.entries(path).find_all{|entry| !['contents','handle','dublin_core.xml','license.txt'].include?(entry)}
  entries = import_files.select {|v| File.extname(v)[1..-1] == 'txt'} 
  entry = entries.empty? ? import_files.first : entries.first
  full_path = File.join(path, entry)
  doc = folder.documents.create(
    :name => entry,
    :status => 0,
    :attachment => File.open(full_path),
    :attachment_file_type => File.extname(full_path)[1..-1]
  )  
  
  puts " |-> Importing document : \"#{entry}\" -->" + (doc.errors.empty? ? "[Success]" : ["[Error]",doc.errors.messages].join(' ') )
  Nokogiri::XML([path,'dublin_core.xml']*'/').xpath('//dcvalue').each do |node|
    doc.metadatas.create(
      :key => "#{(node['qualifier']+'_') if node['qualifier'] != 'none'}#{node['element']}",
      :value => node.text
    )
  end
  doc.save!
end

def import_dspace_dump(path)
  folder = Folder.root.children.create(:name => path)
  Dir.foreach(path) do |entry|
    next if (entry == '..' || entry == '.')
    full_path = File.join(path, entry)
    if File.directory?(full_path)
      puts "---> Creating Directory : \"DSpace_#{entry}\""
      children_folder = folder.children.build(:name => "DSpace_#{entry}")
      children_folder.save!
      create_document_from_folder(full_path, folder)
    end
  end
end
=end





def import_dir(options = {})
  options = {:path => "#{Rails.root}/import/", :name => nil, :dspace => false, :folder => Folder.root, :tree => 0}.merge!(options)
  path, name = options[:path], (options[:name] || File.basename(options[:path]))
  count, tname, tree, spaces = 1, name, options[:tree], " "*(options[:tree]*2)
  until options[:folder].children.find_by_name(name).nil? 
   name = "#{tname} (#{count})"
   count += 1
  end
  
  puts "#{spaces}|--> Creating Directory : \"#{name}\""
  folder = options[:folder].children.create(:name => name) 
  folder.save! 

  Dir.foreach(path) do |entry|
    next if (entry == '..' || entry == '.')
    begin
    full_path = File.join(path, entry)
    if File.directory?(full_path)
      if options[:dspace] && !Dir.entries(full_path).find_all{|e| ['contents','handle','dublin_core.xml','license.txt'].include?(e) && !File.directory?(File.join(full_path, e))}.empty?
        import_files = Dir.entries(full_path).find_all{|e| !['contents','handle','dublin_core.xml','license.txt'].include?(e) && !File.directory?(File.join(full_path, e))}
        entries = import_files.select {|v| File.extname(v)[1..-1] == 'txt'}
        e = entries.empty? ? (import_files.empty? ? nil : import_files.first) : entries.first
        unless e.nil?
          fpath, tname = File.join(full_path, e), e
          until folder.documents.find_by_name(e).nil?
            e = "#{tname} (#{count})"
            count += 1
          end
          file = folder.documents.create(
            :name => e,
            :status => 0,
            :attachment => File.open(fpath),
            :attachment_file_type => File.extname(fpath)[1..-1],
 	    :text_only => true
          )
          puts "#{spaces}  |-> Importing document : \"#{e}\" -->" + (file.errors.empty? ? "[Success]" : ["[Error]",file.errors.messages].join(' ') )
 	  if file.save!
	  print "#{spaces}  |   Getting metadata : #{[full_path,'dublin_core.xml']*'/'}... "
          Nokogiri::XML(File.open(File.join(full_path,'dublin_core.xml'))).xpath('//dcvalue').each do |node|
	    qualifier = node['qualifier'].nil? ? 'none' : node['qualifier']
	    element = node['element'].nil? ? 'none' : node['element']
	    text = node.text.nil? ? 'Unknown' : node.text
            #p "#{(qualifier+'_') if qualifier != 'none'}#{element} => #{text}"
            file.metadatas.create(
              :key => "#{(qualifier+'_') if qualifier != 'none'}#{element}",
              :value => text
            )
          end
	  puts "#{file.metadatas.length} found."
 	  end
        end
      else
        import_dir({:path => full_path, :name => entry, :dspace => options[:dspace], :folder => folder, :tree => tree+1})
      end
    elsif !options[:dspace]
      file = folder.documents.create(:name => entry, :status => 0, :attachment => File.open(full_path), :attachment_file_type => File.extname(full_path)[1..-1], :text_only => true)
      puts "#{spaces}  |-> Importing document : \"#{entry}\" -->" + (file.errors.empty? ? "[Success]" : ["[Error]",file.errors.messages].join(' ') )
    end
  rescue => e
    puts "[ERROR] => #{e.message} | #{e.backtrace}"
  end
  end
=begin
  if options[:dspace]
    import_files = Dir.entries(path).find_all{|entry| !['contents','handle','dublin_core.xml','license.txt'].include?(entry) && !File.directory?(File.join(path, entry))}
    import_files.sort! { |a,b| a.downcase <=> b.downcase }
    entries = import_files.select {|v| File.extname(v)[1..-1] == 'txt'}
    entry = entries.empty? ? (import_files.empty? ? nil : import_files.first) : entries.first
    unless entry.nil?
      full_path = File.join(path, entry)
      file = folder.documents.create(
        :name => entry,
        :status => 0,
        :attachment => File.open(full_path),
        :attachment_file_type => File.extname(full_path)[1..-1]
      )
      puts "#{spaces}  |-> Importing document : \"#{entry}\" -->" + (file.errors.empty? ? "[Success]" : ["[Error]",file.errors.messages].join(' ') )
    end
  end
=end
end

#import_dir "#{Rails.root}/import/"
#import_dir "/data/thesis2/art1"
#import_dir "/data/thesis2/export/1000/"
import_dir :path => "/home/passenger/corpus/", :dspace => false
