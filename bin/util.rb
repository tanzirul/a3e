
module UTIL
require 'fileutils'
	def UTIL.compare(file_name1, file_name2)
		is_same=FileUtils.compare_file(file_name1, file_name2);
	end
	
	def UTIL.extract_num(file_name)
		num=IO.readlines(file_name)
	end
	
	def UTIL.compare_output(file1, file2, file3)
		
		f1 = IO.readlines(file1).map(&:chomp)
		f2 = IO.readlines(file2).map(&:chomp)
		f3= (f1-f2)
		print "*******\n"
		print f3
		print "\n*******\n"
		File.open(file3,"w"){ |f| f.write((f1-f2).join("\n")) }
	
	end
end