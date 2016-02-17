#!/usr/bin/env python
import os

from sys import argv
script, newHostName = argv

print "Modifying network file..."
target = open("/etc/sysconfig/network","w")
target.truncate()
target.write("NETWORKING=yes\n")
target.write("HOSTNAME=")
target.write(newHostName)
target.write("\n")
target.close()

print "Modifying hosts file..."
target = open("/etc/hosts","w")
target.truncate()
target.write("127.0.0.1 ")
target.write(newHostName)
target.write(" localhost.localdomain localhosts\n")
target.close()

print "Set new hostname to %r" % newHostName
os.system('/bin/hostname ' + newHostName)
