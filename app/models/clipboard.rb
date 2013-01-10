class Clipboard
  def initialize
    setup
  end

  def folders
    Folder.find_all_by_id(@folders)
  end

  def files
    Document.find_all_by_id(@documents)
  end

  def add(item)
    if item.class == Folder
      @folders << item.id unless @folders.include?(item.id)
    else
      @documents << item.id unless @documents.include?(item.id)
    end
  end

  def remove(item)
    if item.class == Folder
      @folders.delete(item.id)
    else
      @documents.delete(item.id)
    end
  end

  def empty?
    (@folders.empty? || folders.empty?) && (@documents.empty? || files.empty?)
  end

  def reset
    setup
  end

  private

  def setup
    @folders, @documents = [], []
  end
end
