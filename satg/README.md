
Static Activity Transition Graph Creation
---------------------------------------------
Modify the following parameter in the wala.properties file as per your system. For example in MacOS X this path may be something
similar:

	java_runtime_dir = /Library/Java/JavaVirtualMachines/jdk1.7.0_25.jdk/Contents/Home/jre/lib

This is actually the path that contains the rt.jar or classes.jar file. This file contains the initial java classes that are loaded
by the JVM when a java program runs.

After that, run 
	
	./apk2satg.sh your_apk.apk
	
The procedure may take several minutes depending on the size of the apk. The output will be two files,

your_apk.apk.g.xml: This xml file will contain the relation between parent and child activties.
your_apk.apk.g.dot: This dot file is for visualization purpose.

 
