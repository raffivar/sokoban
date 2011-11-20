@filename_lines = count = File.foreach("test.txt").inject(0) {|c, line| c+1}
puts @filename_lines