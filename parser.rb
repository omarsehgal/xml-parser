#!/usr/intel/bin/ruby1.82

=begin
parsing the xml file in the context of teams
hence we need a class that has all the team elements
some elements in this program seem an overkill - just added them to practice ruby
=end

module DaHelp
	
    MAX_TEAMS = 10

    class Team
	@@team_count = 0
	attr_accessor :tname, :members, :admin, :site, :team_count

	def initialize(tname, site)
		@tname = tname
		@site = site
		@members = Array.new
		@@team_count += 1	
	end
	
	def to_s
		puts "Team: #{@tname}\nSite: #{site}\nAdmin: #{admin}\nMembers: #{members}"
	end

	def list_members
		print "Members: "
		members.each {|m| print "#{m}, "}
	end

	def print_team
		puts "\nTeam: #{@tname}" + ", Site: " + @site + ", Admin: " + @admin + ", # members: #{members.length}"
		list_members
	end

	def self.find_by_name(tname)
		found = nil
		ObjectSpace.each_object(Team){ |o|
			found = o if o.tname == tname
		}
		found
	end

	def Team.team_count
		@@team_count 
	end

	def method_missing(name, *args)
		puts "-E- unknown method #{name}"
	end
    end
end

########################## end class code - begin main program ##################################################

st = 0
site = "US"
team = "DB"
admin = 0
listt = 0
team_hash = {}
lines = IO.readlines("/nfs/site/home/osehgal/bin/ruby/xml_parse/teamData.xml")

require 'optparse'
options = {}

OptionParser.new do |o|
	o.on('-s [SITE_NAME]','choices are US or IDC, default is US') { |site| options[:site] = site }
	o.on('-t [TEAM_NAME]', 'default is DB') { |team| options[:team] = team }
	o.on('-a','list site admin') { admin = 1 }
	o.on('-l','list all teams at site') { listt = 1 }
	o.on('-h','--help','display this message')	{puts o; exit}
	o.parse!
end

tname = ''
lines.each do |line|
	if line =~ /team name="(.*-#{site})"/ or st == 1
		if st == 0
			tname = $1
			team_hash[tname] = DaHelp::Team.new(tname, site)
			st = 1
		end

		if line =~ /<user /
			line =~ /name="(\w+)"/
			uname = $1
			team_hash[tname].members.push(uname)
			team_hash[tname].admin = uname if line =~ /admin/
		end
				
		if line =~ /<\/userlist>/
			st = 0
		end
	end
end

puts "-I- #{DaHelp::Team.team_count} #{site} teams scanned"

# just display the team admin
if admin == 1
	concat = team + '-' + site
	puts "-I- ah, found admin for team #{concat}: " + team_hash[concat].admin
end

# just display the team list
if listt == 1
	team_hash.each do |key,value|
		puts team_hash[key].tname
	end
end	

# now let's also display info on the team
#puts Team.find_by_name(concat)

count = 0
ObjectSpace.each_object(DaHelp::Team){ |o|
	count += 1
}

if count > DaHelp::MAX_TEAMS
	puts "-W- there are way too many teams: #{count}. \nFYI, allowed (well, recommended actually) limit is: #{DaHelp::MAX_TEAMS}"
end

#res = count <=> DaHelp::MAX_TEAMS
#puts "-I- <=> returned #{res}"

=begin
# creating a test block
def myblock(num)
	x = 1
	while x <= num
	    yield x
	    x += 1
	end
end
=end

#myblock(10) { |c| puts "..and a #{c}" }


# not using the below class
class Site < DaHelp::Team
	def initialize(sname)
		super(tname)
		@sname = sname
	end
	
	attr_accessor :sname

	def to_s
#		super + ", #{tname}"
		puts "Site: #{sname}, Team: #{tname}, \
			Admin: #{admin}, Members: " + members.inspect
	end
end
#################################################
