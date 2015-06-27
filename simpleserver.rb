require 'socket'
require 'json'
server = TCPServer.open(80)


loop  {
    client = server.accept
    action = ""
    while line = client.gets   # Thanks Tommy Noe for the blog post about this
      action += line
      break if action =~ /\r\n\r\n$/ 
    end 
    puts "action: #{action}"
    body_size = action.split(' ').last.to_i
    body = client.read(body_size)
    packet = action.split(' ')
    if packet[0] == "GET"
      path = packet[1].to_s   # gotta sanitize or bad things can happen eg '.. .. .. etc/passwords ' 
      if File.file?(path)
        f = File.open(path)
        response= f.read
        f.close
        client.print "HTTP/1.1 200 OK\r\n" +
                 "Content-Type: text/plain\r\n" +
                 "Content-Length: #{response.bytesize}\r\n" +
                 "Connection: close\r\n"
        client.print "\r\n"
        client.print response
        client.close
      else #(no file present)
        message = "File not found"
        # respond with a 404 error code to indicate the file does not exist
        client.print "HTTP/1.1 404 Not Found\r\n" +
                 "Content-Type: text/plain\r\n" +
                 "Content-Length: #{message.size}\r\n" +
                 "Connection: close\r\n"

        client.print "\r\n"
        client.print message
        client.close
      end
    
    elsif packet[0] == "POST"
      path = action.split(' ')[1].to_s
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

  

