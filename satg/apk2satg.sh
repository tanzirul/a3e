echo "Static Activity Translation Graph Generator."
echo "CS, UCR"
echo "Processing dex file."
START=$(date +%s)
java -Xmx6g -jar sap.jar --android-lib=lib/android-2.3.7_r1.jar $1 | grep "<activity>" > $1".g"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Processed in $DIFF seconds." 
echo "Generating output file."
if [ -f $1".g" ]
then
	java -jar satg.jar $1".g"
	rm $1".g"
else
	echo "Error processing SATG"
fi