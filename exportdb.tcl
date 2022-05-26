package require sqlite3

sqlite3 db db

proc timetostring num {
	set minute [expr {$num / 60}]
	set second [expr {$num % 60}]
	return [format "%d:%02d" $minute $second]
}

set outfile [open ytj-funnies.txt w]

set episodes [db eval {select distinct episode from funnies order by episode}]
foreach episode $episodes {
	puts $outfile "--- Episode $episode ---"
	db eval {select * from funnies where episode = $episode order by time} {
		puts $outfile [string cat [timetostring $time] [expr {[expr {$comment ne ""}] ? " $comment" : ""}]]
	}
}

close $outfile
puts "Successfully exported db to ytj-funnies.txt"
