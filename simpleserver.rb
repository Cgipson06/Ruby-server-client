require 'socket'
require 'json'
server = TCPServer.open(80)

puts "Simple Ruby Server initialized, "
loop  {
    puts "   awaiting connections..."
    client = server.accept
    puts "Connection established, listening to port 80..."
    action = ""
    while line = client.gets   # Thanks johnwquarles for the blog post about this gets loop method
      action += line
      break if action =~ /\r\n\r\n$/ #The while will terminate with the end of the get request, but the post needs this to break out the header to get the message size
    end 
    puts "Request recieved:   #{action}"
    puts ""
    body_size = action.split(' ').last.to_i  
    body = client.read(body_size)
    packet = action.split(' ')
    if packet[0] == "GET"
      path = packet[1].to_s   # I should really sanitize or bad things can happen eg '.. .. .. etc/passwords ' 
      if File.file?(path)
        f = File.open(path)
        response= f.read
        f.close
        puts "Sending #{path}"
        client.print "HTTP/1.1 200 OK\r\n" +
                     "Content-Type: text/plain\r\n" +
                     "Content-Length: #{response.bytesize}\r\n" +
                     "Connection: close\r\n\r\n"
        client.print response
        client.close
      else #(no file present)
        message = "File not found"
        client.print "HTTP/1.1 404 Not Found\r\n" +
                     "Content-Type: text/plain\r\n" +
                     "Content-Length: #{message.size}\r\n" +
                     "Connection: close\r\n\r\n"  
        client.print message
        client.close
      end
    
    elsif packet[0] == "POST"
      path = packet[1].to_s
      if File.file?(path)      
         params = JSON.parse(body)
         generated = "<li>Name: #{params['viking']['name']}</li><li>Email: #{params['viking']['email']}</li>"
         f= File.open(path)
         file_content= f.read
         f.close
         content_body = file_content.gsub("<%= yield %>", generated)
         client.print "HTTP/1.1 200 OK\r\n" +
                      "Content-Type: text/plain\r\n" +
                      "Content-Length: #{content_body.bytesize}\r\n" +
                      "Connection: close\r\n"
         client.print(content_body)
         client.close
      end
    end
  }

  

