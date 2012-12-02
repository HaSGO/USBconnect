#! /usr/bin/ruby
require 'digest'
require 'logger'
require 'rubygems'
require 'twitter'
 
pwdFile=ARGV[0]	
authFile=ARGV[1]
devFile=ARGV[2]
logFile="usbConnect.log"
begin #for the exceptions

fileToCheck=File.open(authFile.chomp)
filePasswd=File.open(pwdFile.chomp)
log = Logger.new(logFile, 2, 10*1024)#logs, two files, max 10*1024 bytes
log.datetime_format = "%D-%H:%M:%S"
log .level=Logger::DEBUG
name=nil
password=nil

while (line=fileToCheck.gets)!=nil
#	puts line
	name=line.chomp.split(":",2)[1] if (line =~ /User:.*/)==0 
	password=line.chomp.split(":",2)[1] if (line =~ /Password:.*/)==0	
	token=line.chomp.split(":",2)[1] if (line =~ /Token:.*/)==0
	tokenSecret=line.chomp.split(":",2)[1] if (line =~ /TokenSecret:.*/)==0
end
if (name==nil||password==nil)
	log.warn "File is not well-formed"
end

#name=name.chomp.split(":",2)[1]
#password=password.chomp.split(":",2)[1]
#print name," ",password,"\n"
#Md5 digest for the password, we have to check into filePasswd
cript=Digest::MD5.hexdigest(password)

#puts name
#print cript,"END\n"
flag=0
while(line=filePasswd.gets)!=nil
	namePasswd=line.chomp.split(":",2)
	next if namePasswd.length != 2
#	p namePasswd
	if(namePasswd[0]==name)
		if(namePasswd[1]==cript)
			print name," authenticated\n"
			log.info name+" is now authenticated"
			flag=1
			break
		end
	end
end
fileToCheck.close
filePasswd.close
log.warn("Authentication failed: "+name) if flag==0
exit if flag==0
#the user is authenticated
#token,token_secret=tweetTokens.split(":",2);
if (token==nil || tokenSecret==nil)	
		log.info("No twitter account for this profile")
		exit
	end

sleep 8
if (File.exists?(devFile))
	log.info("USB key used as storage device")
	exit
end

#provide a twitter account only for this app, this oauth is so baaaaaaad!
#or provide a web application to obtain the token
Twitter.configure do |config|
	config.consumer_key = ''
	config.consumer_secret = ''
	config.oauth_token = token
	config.oauth_token_secret = tokenSecret
end
 
Twitter.update(name+" has been authenticated ["+Time.now.to_s+"] @HackerSpaceGO")

log.info(name+" twitter update");


#EXCEPTION
rescue SystemExit
#log.info("EXIT")
rescue Exception
	log.warn($!.to_s)
ensure
	fileToCheck.close
	filePasswd.close
end
