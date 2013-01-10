module ScansHelper
	def scan_status(i)
		status = [
			t(:initialisation),
			t(:checking_for_palgiarism),
			t(:retrieving_web_contents)
		]
		if i 
			status[i]
		else
			t(:not_started_yet)
		end
	end
end
