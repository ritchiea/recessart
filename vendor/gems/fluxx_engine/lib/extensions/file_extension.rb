class File
  def read_whole_file
    file_contents = ''
    while(line = self.gets)
      file_contents += line
    end
    file_contents
  end
end
