# Minimal http server.
# Gets a POST request and then returns some stuff from the server.

require 'rubygems'
require 'aws-sdk-s3'
require 'open3'
require 'socket'               # Get sockets from stdlib

def write_to_aws(name)
  s3 = Aws::S3::Resource.new(region: 'us-west-1')
  obj = s3.bucket('audire-test-bucket').object("#{name}.mp3")
  obj.upload_file("/home/pan/giskards-positronic-brain/visual-classifier/sonicpi/#{name}.mp3", acl:'public-read')
  obj.public_url
end

server = TCPServer.open(2000)  # Socket to listen on port 2000
loop {                         # Servers run forever
  client = server.accept       # Wait for a client to connect
  method, path = client.gets.split                    # In this case, method = "POST" and path = "/"
  headers = {}
  while line = client.gets.split(' ', 2)              # Collect HTTP headers
    break if line[0] == ""                            # Blank line means no more headers
    headers[line[0].chop] = line[1].strip             # Hash headers by type
  end
  data = client.read(headers["Content-Length"].to_i)  # Read the POST data as specified in the header

  input_string = data
  str1_markerstring = "START"
  str2_markerstring = "END"
  parsed_file = input_string[/#{str1_markerstring}(.*?)#{str2_markerstring}/m, 1]



  m_name = Time.now.strftime("%m:%d:%Y-%I:%M%p")
  #link = write_to_aws(m_name)

  c_name = "#{m_name}.wav"
  response = "Nothing to see here"

  file = File.new("/home/pan/giskards-positronic-brain/visual-classifier/sonicpi/#{m_name}.rb", "w")
  file.puts parsed_file
  file.rewind

  ## TODO
  system("./press-key.sh #{m_name}")

  # File is saved to a wav, lets compress it!
  file_route = "/home/pan/giskards-positronic-brain/visual-classifier/sonicpi/#{m_name}"

  system("ffmpeg -i #{file_route}.wav -codec:a libmp3lame -qscale:a 2 #{file_route}.mp3")

  puts "Calling aws"
  #link = write_to_aws(m_name)
  puts "Im done here"
  #puts link
  client.print "HTTP/1.1 200 OK\r\n" +
               "Content-Type: text/plain\r\n" +
               "Content-Length: #{m_name.bytesize}\r\n" +
               "Connection: close\r\n"

  # Print a blank line to separate the header from the response body,
  # as required by the protocol.
  client.print "\r\n"

  #puts c_name
  # Print the actual response body, which is just "Hello World!\n"

  client.print m_name
  #client.print link
  client.close                 # Disconnect from the client

  link = write_to_aws(m_name)
}


