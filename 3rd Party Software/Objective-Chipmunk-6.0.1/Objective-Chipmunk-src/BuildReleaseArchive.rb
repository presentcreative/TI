VERS = ARGV[0]
raise("No version number!") unless VERS

def system(command)
	puts command
	Kernel.system(command)
end

system("/Applications/Doxygen.app/Contents/Resources/doxygen Doxyfile")
system("yes | iphonestatic.command")

# Build the release
dir = "/tmp/Objective-Chipmunk-#{VERS}"

system("rm -rf #{dir}")
system("mkdir -p #{dir}")

system("svn export . #{dir}/Objective-Chipmunk-src")
system("git-export ../Chipmunk #{dir}/Chipmunk")
system("(cd #{dir}/Chipmunk/doc/doc-src && ruby make_docs.rb)")

system("cp -R doxygen/doxygen #{dir}/doxygen")
system("ln -s doxygen/index.html #{dir}/API-Docs.html")

system("cp -R Objective-Chipmunk-iPhone #{dir}")

system("mv #{dir}/Objective-Chipmunk/README.html #{dir}")

system("tar -C /tmp -czf Objective-Chipmunk-#{VERS}.tgz Objective-Chipmunk-#{VERS}/")

system("open #{dir}")

# Build the trial
dir = "/tmp/Objective-Chipmunk-trial-#{VERS}"

system("rm -rf #{dir}")
system("mkdir -p #{dir}")

system("cp -R doxygen/doxygen #{dir}/doxygen")
system("ln -s doxygen/index.html #{dir}/API-Docs.html")

system("cp -R Objective-Chipmunk-trial #{dir}")

system("mv #{dir}/Objective-Chipmunk/README.html #{dir}")

system("tar -C /tmp -czf Objective-Chipmunk-trial-#{VERS}.tgz Objective-Chipmunk-trial-#{VERS}/")

system("open #{dir}")
