package require sqlite3

sqlite3 db db
db eval {create table if not exists funnies(episode integer, time integer, comment string)}

puts "Welcome to the YTJ Funnies utility! Type 'help' if you need help."

set ep 1

proc strtotime str {
	set result [regexp {(?:(\d{1,2}):)?(\d{1,2})} $str match minute second]
	if {!$result} {return -1}
	if {$minute eq ""} {set minute 0}
	return [expr {int($minute) * 60 + int($second)}]
}

proc timetostr num {
	set minute [expr {$num / 60}]
	set second [expr {$num % 60}]
	return [format "%d:%02d" $minute $second]
}

proc prompt {} {
	global ep
	puts -nonewline "Episode $ep > "
	flush stdout

	set input [split [gets stdin]]
	switch -nocase [lindex $input 0] {
		help {
			puts "You can use the following commands:"
			puts "new TIME (COMMENTS) - Insert an entry into the database at time mm:ss"
			puts "list EPISODE - Lists all the funnies in a particular episode"
			puts "ep NUMBER - Change current episode number"
			puts "exit - Close this utility"
			return 1
		}
		new {
			if {[llength $input] < 2} {puts "Be sure to include a timestamp with your entry!";return 1}

			set time [strtotime [lindex $input 1]]
			if {$time eq -1} {puts "The correct time format is mm:ss";return 1}
			set comments [join [lrange $input 2 end]]
			
			puts "Episode $ep, [timetostr $time]. [expr {[expr {$comments ne ""}] ? $comments : "(No comment)"}]"
			puts -nonewline "Confirm insertion (Y/n): "
			flush stdout
			set choice [gets stdin]
			if {$choice eq "n"} {puts "Canceled.";return 1}

			db eval {insert into funnies values($ep, $time, $comments)}
			puts "Success!"
			return 1
		}
		list {
			set numfunnies 0
			db eval {select * from funnies where episode = $ep order by time} {
				incr numfunnies
				puts [string cat [timetostr $time] [expr {[expr {$comment ne ""}] ? " $comment" : ""}]]
			}
			if {$numfunnies == 0} {puts "No funnies in this episode :("}
			return 1
		}
		ep {
			if {[llength $input] < 2} {puts "You forgot an episode number!";return 1}
			if {![regexp {\d+} [lindex $input 1]]} {puts "That's not a number!"; return 1}
			set ep [lindex $input 1]
			return 1
		}
		exit {
			return 0
		}
		default {
			puts "Unrecognized command!"
			return 1
		}
	}
}

while 1 {
	if {![prompt]} exit
}
