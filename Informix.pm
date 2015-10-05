#!/opt/perl/bin/perl

package Informix;
require DBI;

sub new
{
	my ($class, $db, $server) = @_;
	my $self = {
		db => $db,
		server => $server,
		source => $server,
	};
	bless $self, $class;
	return $self;
}

sub connect
{
	my ($self, $username, $password, $override) = @_;
	if (defined $self->{dbh} && $override == 0) {
		$self->${dbh};
	} else {
		$self->{dbh} = DBI->connect("dbi:Informix:$self->{db}", $self->{user}, $self->{password}, {RaiseError => 0, PrintError => 1, AutoCommit => 1}) or die "Could not connect to server: $?\n";}
}

sub getResults
{
	# return array of array for multiple columns
	my @aaResults;
	# return array for single columns
	my @aResults;
	# return string for a single value
	my $result;

	my ($self, $sql) = @_;
	print "You must indicate an SQL statement\n" if !defined($sql);
	exit 1 if !defined($sql);
	my $sth = $self->{dbh}->prepare($sql);
	$sth->execute();
	while(@r = $sth->fetchrow_array) {
		push @aaResults, [@r];
	}

	my @aColCnt = $aaResults[0];

	if ( ( scalar @aaResults == 1 ) && ( scalar @aColCnt == 1 ) ) {
		my $result = $aaResults[0][0];
		$result =~ s/^\s+//;
		$result =~ s/\s+$//;
	 	return $result;
	} elsif (scalar @aColCnt > 1) {
		return @aaResults;
	# I don't this is getting hit!
	} elsif (scalar @aColCnt == 1) {
		foreach my $r(0..$#aaResults) {
			foreach my $c(0..$#{$aaResults[$r]}) {
				push @aResults, $aaResults[$r][$c];
			}
		};
		my @aResults = grep(s/\s*$//g, @aResults);
		return @aResults;
	}
}

sub runSql
{
	my ($self, $sql) = @_;
	print "You must indicate an SQL statement\n" if !defined($sql);
	exit 1 if !defined($sql);
	print $sql . "\n";
	my $sth = $self->{dbh}->prepare($sql);
	my $returnCode = $self->{dbh}->do($sql);
	return $returnCode
}

sub getTables
{
	my ($self) = @_;
	my $sql = "SELECT tabname from systables where tabid > 99 and tabtype = 'T' order by tabname";
	my @aResults = $self->getResults($sql);
	my @aResults = grep(s/\s*$//g, @aResults);
	my @aFinalResults;
	foreach my $r(@aResults) {
		my $string = "$self->{db}:$r";
		push(@aFinalResults, $string);
	}
	return @aFinalResults;
}

sub getColumns
{
	my ($self, $table) = @_;
	my $sql = "SELECT colname from syscolumns a, systables b where a.tabid = b.tabid and b.tabname = \'$table\'";
	my @result = $self->getResults($sql);
	return @result;
}

sub getDatabases
{
	my ($self) = @_;
	my @databases;
	my @db = DBI->data_sources('Informix');
	foreach my $db(@db) {
		my @array = split(/:/,$db);
		my @array = split(/\@/,$array[2]);
		push(@databases,$array[0]);
	}
	return @databases;
}

sub getTableOwner
{
	my ($self, $table) = @_;

	my $sql = "SELECT owner from systables where tabname = '$table'";
	my $owner = $self->getResults($sql);
	return $owner;
}

sub updateStats
{
	my ($self,$table) = @_;
	my $sql = "UPDATE STATISTICS FOR TABLE $table";
	$self->runSql($sql);
}

sub updateStatsLow
{
	my ($self,$table) = @_;
	my $sql = "UPDATE STATISTICS LOW FOR TABLE $table DROP DISTRIBUTIONS";
	$self->runSql($sql);
}
	

sub getDate
{
	my ($self) = @_;
	chomp(my $date=`date +%Y-%m-%d\\ %H:%M:%S`);
	return $date;
}

sub checkStatus
{
	my ($self) = @_;
	my $sql = 'SELECT sh_mode from sysshmvals';
	my $result = $self->getResults($sql);
	return $result;
}

sub checkLogs
{
	my ($self) = @_;
	#my $sql = "SELECT count(*) from syslogs where is_backed_up = 0";

	# changed by marha41 140904, don't count newly added logs!
	my $sql = "SELECT count(*) from syslogs where is_backed_up = 0 and is_new != 1";
	my $result = $self->getResults($sql);
	return $result;
}

sub checkChunks
{
	my ($self) = @_;
	
	my $sql = "SELECT name[1,8] dbspace, round((sum(nfree)) / (sum(chksize)) * 100, 2) percent_free FROM sysdbspaces d, syschunks c WHERE d.dbsnum = c.dbsnum group by 1 order by 1";
	my @result = $self->getResults($sql);
	return @result;
}

sub checkWaits
{
	my ($self) = @_;
	my $sql = "SELECT count(*) from sysseswts";
	my $result = $self->getResults($sql);
	return $result;
}
