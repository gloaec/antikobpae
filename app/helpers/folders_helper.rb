module FoldersHelper
  
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
