require 'socket'
require 'json'

host = 'localhost'     # The web server
port = 80                           # Default HTTP port

puts "Welcome to ConsoleBrowser by Cody"
printf "You may 'get' or 'post', what is your choice?:"
input = gets.chomp.downcase
puts""

if input == 'get'
  path = "./index.html"                 # The file we want 
  request = "GET #{path} HTTP/1.0\r\n\r\n"# This is the HTTP request we send to fetch a file
  socket = TCPSocket.open(host,port)  # Connect to server
  socket.print(request)               # Send request
  response = socket.read              # Read complete response
  # Split response at first blank line into headers and body
  headers,body = response.split("\r\n\r\n", 2) 
  print body 

else
  printf "Please enter the name of the person you would like to sign up:"
  name = gets.chomp
  puts ""
  printf "Please enter #{name}'s email address: "
  email = gets.chomp
  signup = Hash[:viking,Hash[:name, name, :email,email]].to_json
  path = './thanks.html'
  message = "POST #{path} HTTP/1.0\r\nFrom: Cgipson06@aol.hotmail.com\r\n" +
                 "User-Agent: ConsoleBrowser\r\nContent-Type:  application/json\r\n" +
                 "Content-Length: #{signup.size}\r\n\r\n" +
                 "#{signup}\r\n"
  socket = TCPSocket.open(host,port)  # Connect to server
  socket.print(message)  
  response = socket.read
  puts ""
  print "sent POST request:  #{message}"
  puts""
  print response
end
  
  

