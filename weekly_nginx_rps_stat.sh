filemask=$FILEMASK # specify file mask to seek, for example, sitename.access
recipient=$RECIPIENT # recipients of the mail. you can specity multiple recipients separated by space 

echo "Weekly RPS report for `hostname -f` for week #`date +%V` (`date -d'monday-7 days' +%Y-%m-%d` — `date -dsunday +%Y-%m-%d`)" > /tmp/rpsres.txt

function logs_array {
	file_list=()
	while IFS= read -d $'\0' -r file ; do
    		file_list=("${file_list[@]}" "$file")
	done < <(find "/var/log/nginx/" -mtime -7 -name *$filemask* -print0)
}	

function calc_rps {
	for rps in "${file_list[@]}"
	do
		awk '{print $4}' $rps | sort | uniq -c | awk '{print $1}' | sort -n > /tmp/rps.txt
	done
}

function get_percentile {
	linesTotal=$(cat /tmp/rps.txt | wc -l)
    	percentile=$1
    	linesPercentile=$(bc <<< "($linesTotal * 0.$percentile)/1")
    	echo
    	echo $percentile percentile
    	head -n $linesPercentile /tmp/rps.txt | tail
}

get_percentile 95 >> /tmp/rpsres.txt
get_percentile 99 >> /tmp/rpsres.txt

echo >> /tmp/rpsres.txt
echo Peak >> /tmp/rpsres.txt
tail /tmp/rps.txt >> /tmp/rpsres.txt

# send mail
mail -s "Weekly RPS report for `hostname -f` for week #`date +%V` (`date -d'monday-7 days' +%Y-%m-%d` — `date -dsunday +%Y-%m-%d`)" $recipient < /tmp/rpsres.txt
